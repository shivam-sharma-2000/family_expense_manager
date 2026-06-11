import 'dart:async';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_manager/features/expense/data/models/expense_model.dart';
import 'package:expense_manager/features/expense/data/datasources/local/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../../domain/entities/expense.dart';
import '../datasources/remote/expense_remote_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper databaseHelper;
  final ExpenseRemoteDataSource remote;
  String? _lastUserId;
  String? _lastFamilyId;
  final StreamController<List<Expense>> _expensesController =
      StreamController<List<Expense>>.broadcast();

  ExpenseRepositoryImpl({required this.databaseHelper, required this.remote});

  @override
  Future<String> addExpense(Expense expense) async {
    final db = await databaseHelper.database;
    final expenseModel = ExpenseModel.fromEntity(expense);
    final map = expenseModel.toMap();

    // 1. Save locally FIRST so the UI updates instantly
    map[DatabaseHelper.columnIsSynced] = 0; // Not synced initially
    
    await db.insert(
      DatabaseHelper.tableExpenses,
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    // 2. Fire and forget remote push
    _pushToRemoteBackground(expenseModel, map[DatabaseHelper.columnId]);

    // 3. Return the locally generated ID instantly
    return expense.id; 
  }

  Future<void> _pushToRemoteBackground(ExpenseModel expenseModel, String localId) async {
    try {
      await remote.setExpense(expenseModel);
      
      // Update local database with remote ID and mark as synced
      final db = await databaseHelper.database;
      await db.update(
        DatabaseHelper.tableExpenses,
        {
          DatabaseHelper.columnIsSynced: 1,
        },
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      debugPrint('Background sync failed for expense $localId: $e');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await databaseHelper.database;
    final expenseModel = ExpenseModel.fromEntity(expense);
    final map = expenseModel.toMap();
    map[DatabaseHelper.columnIsSynced] = 0;

    await db.update(
      DatabaseHelper.tableExpenses,
      map,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [expense.id],
    );
    _notifyExpensesChanged();

    _pushUpdateToRemoteBackground(expenseModel, expense.id);
  }

  Future<void> _pushUpdateToRemoteBackground(ExpenseModel expenseModel, String localId) async {
    try {
      await remote.updateExpense(expenseModel);
      final db = await databaseHelper.database;
      await db.update(
        DatabaseHelper.tableExpenses,
        {DatabaseHelper.columnIsSynced: 1},
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      debugPrint('Background update failed for $localId: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await databaseHelper.database;
    // Soft delete
    await db.update(
      DatabaseHelper.tableExpenses,
      {
        DatabaseHelper.columnIsDeleted: 1,
        DatabaseHelper.columnIsSynced: 0,
      },
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    _notifyExpensesChanged();

    _pushDeleteToRemoteBackground(id);
  }

  Future<void> _pushDeleteToRemoteBackground(String id) async {
    try {
      await remote.deleteExpense(id);
      final db = await databaseHelper.database;
      // Hard delete locally once synced
      await db.delete(
        DatabaseHelper.tableExpenses,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Background delete failed for $id: $e');
    }
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );
    return List.generate(
      maps.length,
      (i) => ExpenseModel.fromMap(maps[i]).toEntity(),
    );
  }

  @override
  Future<List<Expense>> getExpenses({
    String? userId,
    String? familyId,
    List<String>? userIds,
  }) async {
    // 1. Fetch local data first
    final localData = await _getExpenses(
      userId: userId,
      familyId: familyId,
      userIds: userIds,
    );

    // 2. If we have local data, return it immediately for instant UI
    // and fire remote fetch in the background.
    if (localData.isNotEmpty) {
      _fetchRemoteAndCacheBackground(userId, familyId, userIds);
      return localData;
    }

    // 3. If local DB is empty (first launch), wait for remote fetch
    await _fetchRemoteAndCacheBackground(userId, familyId, userIds);
    return await _getExpenses(
      userId: userId,
      familyId: familyId,
      userIds: userIds,
    );
  }

  Future<void> _fetchRemoteAndCacheBackground(
    String? userId,
    String? familyId,
    List<String>? userIds,
  ) async {
    try {
      final res = await remote.getExpenses(
        userId: userId,
        familyId: familyId,
        userIds: userIds,
      );

      final db = await databaseHelper.database;
      bool hasChanges = false;
      for (final model in res) {
        final map = model.toMap();
        map[DatabaseHelper.columnIsSynced] = 1; 
        await db.insert(
          DatabaseHelper.tableExpenses,
          map,
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
        hasChanges = true;
      }
      
      if (hasChanges) {
        _notifyExpensesChanged();
      }
    } catch (e) {
      debugPrint('Background fetch error: $e');
    }
  }

  // Helper method to get expenses with optional filters
  Future<List<Expense>> _getExpenses({
    String? userId,
    String? familyId,
    List<String>? userIds,
  }) async {
    final db = await databaseHelper.database;

    String where = '${DatabaseHelper.columnIsDeleted} = ?';
    List<dynamic> whereArgs = [0];

    if (userIds != null && userIds.isNotEmpty) {
      where +=
          ' AND ${DatabaseHelper.columnUserId} IN (${List.filled(userIds.length, '?').join(',')})';
      whereArgs.addAll(userIds);
    } else if (userId != null) {
      where += ' AND ${DatabaseHelper.columnUserId} = ?';
      whereArgs.add(userId);
    }

    if (familyId != null) {
      where += ' AND ${DatabaseHelper.columnFamilyId} = ?';
      whereArgs.add(familyId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );

    return List.generate(
      maps.length,
      (i) => ExpenseModel.fromMap(maps[i]).toEntity(),
    );
  }

  @override
  Future<List<Expense>> getExpensesByCategory(
    String category, {
    String? userId,
    String? familyId,
  }) async {
    final db = await databaseHelper.database;

    String where =
        '${DatabaseHelper.columnCategory} = ? AND ${DatabaseHelper.columnIsDeleted} = ?';
    List<dynamic> whereArgs = [category, 0];

    if (userId != null) {
      where += ' AND ${DatabaseHelper.columnUserId} = ?';
      whereArgs.add(userId);
    }

    if (familyId != null) {
      where += ' AND ${DatabaseHelper.columnFamilyId} = ?';
      whereArgs.add(familyId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );

    return List.generate(
      maps.length,
      (i) => ExpenseModel.fromMap(maps[i]).toEntity(),
    );
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      where:
          '${DatabaseHelper.columnDate} >= ? AND ${DatabaseHelper.columnDate} <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );
    return List.generate(
      maps.length,
      (i) => ExpenseModel.fromMap(maps[i]).toEntity(),
    );
  }

  @override
  Future<void> syncWithFirebase() async {
    try {
      final db = await databaseHelper.database;

      // 1. Push all unsynced expenses (new or updated)
      final unsynced = await databaseHelper.getUnsyncedExpenses();
      for (final map in unsynced) {
        final expenseModel = ExpenseModel.fromMap(map);
        try {
          await remote.setExpense(expenseModel);
          // Mark as synced locally
          await db.update(
            DatabaseHelper.tableExpenses,
            {DatabaseHelper.columnIsSynced: 1},
            where: '${DatabaseHelper.columnId} = ?',
            whereArgs: [map[DatabaseHelper.columnId]],
          );
        } catch (e) {
          debugPrint('Failed to sync push expense ${map[DatabaseHelper.columnId]}: $e');
        }
      }

      // 2. Push all soft deletes
      final deletedNotSynced = await databaseHelper.getDeletedButNotSynced();
      for (final map in deletedNotSynced) {
        final id = map[DatabaseHelper.columnId];
        try {
          await remote.deleteExpense(id);
          // Hard delete locally after remote delete succeeds
          await db.delete(
            DatabaseHelper.tableExpenses,
            where: '${DatabaseHelper.columnId} = ?',
            whereArgs: [id],
          );
        } catch (e) {
          debugPrint('Failed to sync delete expense $id: $e');
        }
      }

      // 3. Pull latest from remote
      // We will pull the global dataset for the user/family if identifiers are set
      await _fetchRemoteAndCacheBackground(_lastUserId, _lastFamilyId, null);

    } catch (e) {
      debugPrint('Sync failed: $e');
    }
    _notifyExpensesChanged();
  }

  // Notify listeners that expenses have changed
  void _notifyExpensesChanged() async {
    try {
      final expenses = await _getExpenses(
        userId: _lastUserId,
        familyId: _lastFamilyId,
      );

      if (!_expensesController.isClosed) {
        _expensesController.add(expenses);
      }
    } catch (e) {
      debugPrint('Error notifying expenses changed: $e');
    }
  }

  @override
  void dispose() {
    if (!_expensesController.isClosed) {
      _expensesController.close();
    }
  }

  @override
  Future<List<String>> getExpenseCategories() {
    // TODO: implement getExpenseCategories
    throw UnimplementedError();
  }

  @override
  Future<double> getTotalExpense({DateTime? start, DateTime? end}) {
    // TODO: implement getTotalExpense
    throw UnimplementedError();
  }
}
