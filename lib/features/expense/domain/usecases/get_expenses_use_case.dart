import 'package:expense_manager/core/domain/usecases/usecase.dart';
import 'package:expense_manager/core/utils/typedefs.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';

class GetExpensesUseCase extends NoParamsUseCase<List<ExpenseEntity>> {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  @override
  ResultFuture<List<ExpenseEntity>> call() async {
    try {
      return await _repository.getAllExpenses();
    } catch (e) {
      rethrow;
    }
  }
}

class GetExpensesByDateRangeUseCase extends UseCase<List<ExpenseEntity>, DateRangeParams> {
  final ExpenseRepository _repository;

  GetExpensesByDateRangeUseCase(this._repository);

  @override
  ResultFuture<List<ExpenseEntity>> call(DateRangeParams params) async {
    try {
      return await _repository.getExpensesByDateRange(
        params.startDate,
        params.endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class GetExpensesByCategoryUseCase extends UseCase<List<ExpenseEntity>, String> {
  final ExpenseRepository _repository;

  GetExpensesByCategoryUseCase(this._repository);

  @override
  ResultFuture<List<ExpenseEntity>> call(String category) async {
    try {
      return await _repository.getExpensesByCategory(category);
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
