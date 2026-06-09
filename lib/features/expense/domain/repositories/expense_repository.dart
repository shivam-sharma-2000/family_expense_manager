import 'dart:async';
import '../entities/expense.dart';

/// Contract for the Expense feature's data layer
abstract class ExpenseRepository {
  /// Adds a new expense
  /// Will be saved locally first and synced with Firebase when online
  Future<String> addExpense(Expense expense);

  /// Updates an existing expense
  /// Will be updated locally first and synced with Firebase when online
  Future<void> updateExpense(Expense expense);

  /// Deletes an expense by its ID
  /// Will be marked as deleted locally and synced with Firebase when online
  Future<void> deleteExpense(String id);

  /// Retrieves all expenses
  Future<List<Expense>> getAllExpenses();

  /// Stream of expenses for real-time updates
  Future<List<Expense>> getExpenses({String? userId, String? familyId, List<String>? userIds});

  /// Retrieves expenses by category
  /// Returns a Future for one-time fetch operations
  Future<List<Expense>> getExpensesByCategory(String category);

  /// Retrieves expenses within a date range
  /// Returns a Future for one-time fetch operations
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);

  /// Calculates the total expense, optionally filtered by date range
  /// Returns a Future for one-time calculation
  Future<double> getTotalExpense({DateTime? start, DateTime? end});

  /// Syncs all local changes with Firebase
  /// Call this when the app comes back online
  Future<void> syncWithFirebase();

  /// Get all available expense categories
  Future<List<String>> getExpenseCategories();
}
