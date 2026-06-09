import 'package:expense_manager/core/errors/failure/failure.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class SyncExpense {
  final ExpenseRepository repository;

  const SyncExpense({required this.repository});

  Future<Either<Failure, void>> call() async {
    try {
      await repository.syncWithFirebase();
      return const Right(null);
    } catch (e) {
      return const Left(NetworkFailure());
    }
  }
}
