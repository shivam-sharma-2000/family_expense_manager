import 'package:expense_manager/features/expense/data/models/expense_model.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses({String? userId, String? familyId, List<String>? userIds});

  Future<void> setExpense(ExpenseModel expense);
  
  Future<void> updateExpense(ExpenseModel expense);
  
  Future<void> deleteExpense(String id);
}
