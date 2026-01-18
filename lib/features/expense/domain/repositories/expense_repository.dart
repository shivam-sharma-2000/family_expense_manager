import 'dart:async';
import '../entities/expense_entity.dart';

/// Contract for the Expense feature's data layer
abstract class ExpenseRepository {
  /// Adds a new expense
  /// Will be saved locally first and synced with Firebase when online
  // Future<bool> addExpense(ExpenseEntity expense);

  Future<String> addExpense(ExpenseEntity expense);

  /// Updates an existing expense
  /// Will be updated locally first and synced with Firebase when online
  Future<void> updateExpense(ExpenseEntity expense);
  
  /// Deletes an expense by its ID
  /// Will be marked as deleted locally and synced with Firebase when online
  Future<void> deleteExpense(String id);
  
  /// Retrieves all expenses
  Future<List<ExpenseEntity>> getAllExpenses();
  
  /// Stream of expenses for real-time updates
  Future<List<ExpenseEntity>> getExpenses({
    String? userId,
    String? familyId,
  });
  
  /// Retrieves expenses by category
  /// Returns a Future for one-time fetch operations
  Future<List<ExpenseEntity>> getExpensesByCategory(String category);
  
  /// Retrieves expenses within a date range
  /// Returns a Future for one-time fetch operations
  Future<List<ExpenseEntity>> getExpensesByDateRange(DateTime start, DateTime end);
  
  /// Calculates the total expense, optionally filtered by date range
  /// Returns a Future for one-time calculation
  Future<double> getTotalExpense({DateTime? start, DateTime? end});
  
  /// Syncs all local changes with Firebase
  /// Call this when the app comes back online
  Future<void> syncWithFirebase();
  
  /// Get all available expense categories
  Future<List<String>> getExpenseCategories();
}
