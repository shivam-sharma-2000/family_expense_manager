import 'dart:async';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_manager/features/expense/data/models/expense_model.dart';
import 'package:expense_manager/features/expense/data/datasources/local/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../datasources/remote/expense_remote_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper databaseHelper;
  final ExpenseRemoteDataSource remote;
  String? _lastUserId;
  String? _lastFamilyId;
  final StreamController<List<ExpenseEntity>> _expensesController =
      StreamController<List<ExpenseEntity>>.broadcast();

  ExpenseRepositoryImpl({required this.databaseHelper, required this.remote});

  @override
  Future<String> addExpense(ExpenseEntity expense) async {
    return remote.addExpense(ExpenseModel.fromEntity(expense));
  }

  // Future<bool> addExpense(ExpenseEntity expense) async {
  //   try {
  //     final db = await databaseHelper.database;
  //     final expenseModel = ExpenseModel.fromEntity(expense);
  //
  //     // Ensure the expense has user and family IDs
  //     if (expense.userId != null && expense.userId!.isEmpty) {
  //       throw Exception('User ID is required');
  //     }
  //
  //     final id = await db.insert(
  //       DatabaseHelper.tableExpenses,
  //       expenseModel.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //
  //     if (id > 0) {
  //       _notifyExpensesChanged();
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     // Log the error for debugging
  //     debugPrint('Error adding expense: $e');
  //     return false;
  //   }
  // }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final db = await databaseHelper.database;
    final expenseModel = ExpenseModel.fromEntity(expense);
    await db.update(
      DatabaseHelper.tableExpenses,
      expenseModel.toMap(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [expense.id],
    );
    _notifyExpensesChanged();
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableExpenses,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    _notifyExpensesChanged();
  }

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
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
  Future<List<ExpenseEntity>> getExpenses({
    String? userId,
    String? familyId,
  }) async {
    final res = await remote.getExpenses();
    final list = res.map((e) => e.toEntity()).toList();
    return list;
  }

  // Helper method to get expenses with optional filters
  Future<List<ExpenseEntity>> _getExpenses({
    String? userId,
    String? familyId,
  }) async {
    final db = await databaseHelper.database;

    String where = '${DatabaseHelper.columnIsDeleted} = ?';
    List<dynamic> whereArgs = [0];

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
  Future<List<ExpenseEntity>> getExpensesByCategory(
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
  Future<List<ExpenseEntity>> getExpensesByDateRange(
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
    // This is a placeholder for Firebase sync functionality
    // In a real implementation, you would:
    // 1. Check network connectivity
    // 2. Get all unsynced expenses from local DB
    // 3. Push them to Firebase
    // 4. Update sync status in local DB
    // 5. Handle any errors and retries

    // For now, we'll just mark all expenses as synced
    final db = await databaseHelper.database;
    await db.update(
      DatabaseHelper.tableExpenses,
      {'is_synced': 1},
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    // Notify listeners after sync
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
