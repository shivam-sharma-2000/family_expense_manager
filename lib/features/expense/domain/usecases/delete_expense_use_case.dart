import 'package:expense_manager/core/domain/usecases/usecase.dart';
import 'package:expense_manager/core/utils/typedefs.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase extends UseCase<void, String> {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase(this._repository);

  @override
  ResultFuture<void> call(String id) async {
    try {
      return await _repository.deleteExpense(id);
    } catch (e) {
      rethrow;
    }
  }
}
