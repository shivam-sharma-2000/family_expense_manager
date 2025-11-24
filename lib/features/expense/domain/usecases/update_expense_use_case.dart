import 'package:expense_manager/core/domain/usecases/usecase.dart';
import 'package:expense_manager/core/utils/typedefs.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase extends UseCase<void, UpdateExpenseParams> {
  final ExpenseRepository _repository;

  UpdateExpenseUseCase(this._repository);

  @override
  ResultFuture<void> call(UpdateExpenseParams params) async {
    try {
      return await _repository.updateExpense(params.expense);
    } catch (e) {
      rethrow;
    }
  }
}

class UpdateExpenseParams {
  final ExpenseEntity expense;

  const UpdateExpenseParams({required this.expense});
}
