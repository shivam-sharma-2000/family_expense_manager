import '../enums/api_error_code.dart';
import 'api_error.dart';

/// Represents an exception that occurs during API communication or response processing.
///
/// [ApiException] is thrown when an unexpected error occurs during an API request or response parsing.
/// It includes an [ApiErrorCode] to help classify and handle the error appropriately.
class ApiException implements Exception {
  /// A descriptive message of what went wrong.
  final String message;

  /// Categorized code to identify the type of error.
  final ApiErrorCode errorCode;

  /// Optional structured error metadata from the API.
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    this.errorCode = ApiErrorCode.unknown,
    this.details,
  });

  /// Named constructor for network-related issues.
  factory ApiException.network(String message) =>
      ApiException(message: message, errorCode: ApiErrorCode.networkError);

  /// Factory for creating an exception from an [ApiError] object.
  factory ApiException.fromApiError(ApiError error) => ApiException(
    message: error.message,
    errorCode: error.code,
    details: error.details,
  );

  @override
  String toString() => 'ApiException [$errorCode]: $message';
}
