import 'package:expense_manager/core/domain/usecases/usecase.dart';
import 'package:expense_manager/core/utils/typedefs.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';

class AddExpenseUseCase extends UseCase<ExpenseEntity, AddExpenseParams> {
  final ExpenseRepository _repository;

  AddExpenseUseCase(this._repository);

  @override
  ResultFuture<ExpenseEntity> call(AddExpenseParams params) async {
    try {
      final result = await _repository.addExpense(params.expense);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}

class AddExpenseParams {
  final ExpenseEntity expense;

  const AddExpenseParams({required this.expense});
}
