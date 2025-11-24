import 'package:expense_manager/core/domain/usecases/usecase.dart';
import 'package:expense_manager/core/utils/typedefs.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';

class GetTotalExpenseUseCase extends UseCase<double, DateRangeParams> {
  final ExpenseRepository _repository;

  GetTotalExpenseUseCase(this._repository);

  @override
  ResultFuture<double> call(DateRangeParams? params) async {
    try {
      if (params == null) {
        return await _repository.getTotalExpense();
      }
      return await _repository.getTotalExpense(
        start: params.startDate,
        end: params.endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class GetExpenseCategoriesUseCase extends NoParamsUseCase<List<String>> {
  final ExpenseRepository _repository;

  GetExpenseCategoriesUseCase(this._repository);

  @override
  ResultFuture<List<String>> call() async {
    try {
      return await _repository.getExpenseCategories();
    } catch (e) {
      rethrow;
    }
  }
}

class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}
