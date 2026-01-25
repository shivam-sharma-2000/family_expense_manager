class ExpenseSummary {
  final double totalExpense;
  final double totalIncome;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;

  ExpenseSummary({
    required this.totalExpense,
    required this.totalIncome,
    required this.expenseByCategory,
    required this.incomeByCategory,
  });
}
