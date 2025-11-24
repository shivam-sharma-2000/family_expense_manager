import 'package:expense_manager/features/expense/domain/entities/expense.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_manager/features/expense/data/models/expense_model.dart';
import 'package:expense_manager/features/expense/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper databaseHelper;

  ExpenseRepositoryImpl({required this.databaseHelper});

  @override
  Future<void> addExpense(Expense expense) async {
    final db = await databaseHelper.database;
    final expenseModel = ExpenseModel.fromEntity(expense);
    await db.insert(
      DatabaseHelper.tableExpenses,
      expenseModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await databaseHelper.database;
    final expenseModel = ExpenseModel.fromEntity(expense);
    await db.update(
      DatabaseHelper.tableExpenses,
      expenseModel.toMap(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [expense.id],
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableExpenses,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      where: '${DatabaseHelper.columnDate} >= ? AND ${DatabaseHelper.columnDate} <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableExpenses,
      where: '${DatabaseHelper.columnCategory} = ?',
      whereArgs: [category],
      orderBy: '${DatabaseHelper.columnDate} DESC',
    );
    return List.generate(maps.length, (i) => ExpenseModel.fromMap(maps[i]));
  }

  @override
  Future<double> getTotalExpense({DateTime? start, DateTime? end}) async {
    final db = await databaseHelper.database;
    String query = 'SELECT SUM(${DatabaseHelper.columnAmount}) as total FROM ${DatabaseHelper.tableExpenses}';
    List<String> whereArgs = [];
    
    if (start != null && end != null) {
      query += ' WHERE ${DatabaseHelper.columnDate} >= ? AND ${DatabaseHelper.columnDate} <= ?';
      whereArgs.addAll([
        start.millisecondsSinceEpoch.toString(),
        end.millisecondsSinceEpoch.toString(),
      ]);
    }
    
    final result = await db.rawQuery(query, whereArgs);
    return result.first['total'] as double? ?? 0.0;
  }

  // Close the database when done
  Future<void> close() async {
    await databaseHelper.close();
  }
}
