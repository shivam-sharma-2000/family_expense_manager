import '../../../../core/utils/typedefs.dart';
import '../entities/expense_entity.dart';

/// Contract for the Expense feature's data layer
abstract class ExpenseRepository {
  /// Adds a new expense
  ResultFuture<ExpenseEntity> addExpense(ExpenseEntity expense);
  
  /// Updates an existing expense
  ResultFuture<void> updateExpense(ExpenseEntity expense);
  
  /// Deletes an expense by its ID
  ResultFuture<void> deleteExpense(String id);
  
  /// Retrieves all expenses
  ResultFuture<List<ExpenseEntity>> getAllExpenses();
  
  /// Retrieves expenses within a date range
  ResultFuture<List<ExpenseEntity>> getExpensesByDateRange(
    DateTime start, 
    DateTime end,
  );
  
  /// Retrieves expenses by category
  ResultFuture<List<ExpenseEntity>> getExpensesByCategory(String category);
  
  /// Calculates the total expense, optionally filtered by date range
  ResultFuture<double> getTotalExpense({DateTime? start, DateTime? end});
  
  /// Get all available expense categories
  ResultFuture<List<String>> getExpenseCategories();
}
