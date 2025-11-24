import '../../utils/typedefs.dart';

/// Base use case interface
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  ResultFuture<Type> call(Params params);
}

/// Use case without parameters
abstract class NoParamsUseCase<Type> {
  /// Executes the use case
  ResultFuture<Type> call();
}

/// No parameters class for use cases that don't need parameters
class NoParams {}
