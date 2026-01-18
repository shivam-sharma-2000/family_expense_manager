import 'package:expense_manager/features/expense/data/models/expense_model.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<String> addExpense(ExpenseModel expense);
}
