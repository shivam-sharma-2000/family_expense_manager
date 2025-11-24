// Abstract class representing general failures in the app
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

// Specific failure classes
class ServerFailure extends Failure {
  const ServerFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Extension to convert exceptions to failures
extension ExceptionToFailure on Exception {
  Failure toFailure() {
    if (this is FormatException) {
      return ValidationFailure(toString());
    }
    return Failure(toString());
  }
}

// Extension to handle Either type for error handling
class Either<L, R> {
  final L? left;
  final R? right;
  final bool isLeft;

  Either._(this.left, this.right, this.isLeft);

  factory Either.left(L failure) => Either._(failure, null, true);
  factory Either.right(R value) => Either._(null, value, false);

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (isLeft) {
      return onLeft(left as L);
    } else {
      return onRight(right as R);
    }
  }
}
