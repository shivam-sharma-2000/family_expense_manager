import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import '../entities/expense_summary.dart';

class LoadSummaryUseCase {
  LoadSummaryUseCase();

  Future<ExpenseSummary> call(List<ExpenseEntity> expenses) async {
    double totalExpense = 0;
    double totalIncome = 0;
    final Map<String, double> categoryTotals = {};
    final Map<String, double> incomeCategoryTotals = {};

    for (final expense in expenses) {
      if (expense.amount < 0) {
        totalExpense += expense.amount.abs();
        categoryTotals.update(
          expense.category,
          (value) => value + expense.amount.abs(),
          ifAbsent: () => expense.amount.abs(),
        );
      } else {
        totalIncome += expense.amount;
        incomeCategoryTotals.update(
          expense.category,
          (value) => value + expense.amount.abs(),
          ifAbsent: () => expense.amount.abs(),
        );
      }
    }

    return ExpenseSummary(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      expenseByCategory: categoryTotals,
      incomeByCategory: incomeCategoryTotals,
    );
  }
}
