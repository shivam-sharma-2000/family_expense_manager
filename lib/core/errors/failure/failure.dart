import '../error_messages.dart';

sealed class Failure {
  /// A short, user-facing title of the error.
  final String title;

  /// A detailed description of the error that can be shown in the UI.
  final String description;

  /// Optional asset path to an image or icon representing the error.
  final String imageUrl;

  /// Optional error metadata for debugging or showing detailed messages.
  final Map<String, dynamic>? details;

  const Failure({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.details,
  });
}

/// Represents a failure due to no internet connection.
///
/// Typically used when a network request fails because the user is offline.
final class NetworkFailure extends Failure {
  const NetworkFailure()
    : super(
        title: ErrorMessages.networkErrorTitle,
        description: ErrorMessages.networkError,
        imageUrl: "",
        // imageUrl: AppAssets.noInternet,
      );
}

/// Represents a server-side error (status code 500, etc.).
///
/// Used when the backend fails to process the request correctly.
final class ServerFailure extends Failure {
  const ServerFailure({String? details, Map<String, dynamic>? extraDetails})
    : super(
        title: ErrorMessages.serverErrorTitle,
        description: details ?? ErrorMessages.serverError,
        imageUrl: "",
        // imageUrl: AppAssets.serverError,
        details: extraDetails,
      );
}

/// Represents an unexpected failure not covered by other failure types.
///
/// Catch-all for uncategorized or unknown issues.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String? title, String? description})
    : super(
        title: title ?? ErrorMessages.unexpectedErrorTitle,
        description: description ?? ErrorMessages.unexpectedError,
        imageUrl: "",
        // imageUrl: AppAssets.unexpectedError,
      );
}

/// Represents a failure caused by validation errors (e.g., invalid input).
///
/// You can also pass in extra `details` to show field-specific errors.
final class ValidationFailure extends Failure {
  const ValidationFailure({required String message, super.details})
    : super(
        title: ErrorMessages.validationError,
        description: message,
        imageUrl: "",
        // imageUrl: AppAssets.validationError,
      );
}
