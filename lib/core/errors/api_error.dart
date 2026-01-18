import '../enums/api_error_code.dart';
import 'error_messages.dart';

/// A helper function to parse a string error code into an [ApiErrorCode] enum.
/// If the provided [code] does not match any known values, [ApiErrorCode.unknown] is returned.
ApiErrorCode parseApiErrorCode(String code) {
  switch (code.toLowerCase()) {
    case 'bad_request':
    case '400':
      return ApiErrorCode.badRequest;
    case 'unauthorized':
    case '401':
      return ApiErrorCode.unauthorized;
    case 'forbidden':
    case '403':
      return ApiErrorCode.forbidden;
    case 'not_found':
    case '404':
      return ApiErrorCode.notFound;
    case 'conflict':
    case '409':
      return ApiErrorCode.conflict;
    case 'internal_server_error':
    case '500':
      return ApiErrorCode.internalServerError;
    case 'network_error':
      return ApiErrorCode.networkError;
    case 'parsing_error':
      return ApiErrorCode.parsingError;
    case 'validation_error':
    case 'validation_failed':
      return ApiErrorCode.validationError;
    default:
      return ApiErrorCode.unknown;
  }
}

/// Represents an error returned by the API.
///
/// [ApiError] provides details about an error, including an error [code] as an [ApiErrorCode],
/// a human-readable [message], and optionally, additional [details].
class ApiError {
  /// The error code.
  final ApiErrorCode code;

  /// A human-readable message explaining the error.
  final String message;

  /// Additional error details (if any).
  final Map<String, dynamic>? details;

  ApiError({required this.code, required this.message, this.details});

  /// Named constructor for network errors.
  ApiError.networkError()
    : code = ApiErrorCode.networkError,
      message = ErrorMessages.networkErrorTitle,
      details = null;

  /// Factory constructor to create an [ApiError] from a JSON map.
  ///
  /// The JSON should contain a "status" field that maps to an error code string,
  /// a "message" field with a description, and optionally, "details".
  factory ApiError.fromJson(Map<String, dynamic> json) {
    final rawCode = json['status'] ?? json['code'] ?? json['error_code'];
    return ApiError(
      code: parseApiErrorCode(rawCode?.toString() ?? ''),
      message: json['message'] as String? ?? ErrorMessages.unexpectedErrorTitle,
      details: (json['details'] ?? json['detail']) as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => 'ApiError [$code]: $message';
}
