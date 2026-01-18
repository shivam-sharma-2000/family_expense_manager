import 'dart:developer';

import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/custom_exceptions.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/expense_entity.dart';

/// Use-case: “Get me a page of requests matching these filters.”
final class LoadExpense {
  final ExpenseRepository repository;

  const LoadExpense({required this.repository});

  Future<Either<Failure, List<ExpenseEntity>>> call() async {
    try {
      final res = await repository.getExpenses();
      return Right(res);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ClientException catch (e) {
      return Left(UnexpectedFailure(title: e.message));
    } on ServerException {
      return const Left(ServerFailure());
    } catch (error, stackTrace) {
      log(
        'LoadExpense unexpected error',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnexpectedFailure());
    }
  }
}
