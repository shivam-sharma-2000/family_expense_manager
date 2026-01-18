import '../enums/api_error_code.dart';
import 'api_exception.dart';

/// Thrown when a network error occurs (e.g., no internet connection).
class NetworkException extends ApiException {
  const NetworkException(String message)
    : super(message: message, errorCode: ApiErrorCode.networkError);
}

/// Thrown for client-side errors like 400, 401, or validation failures.
///
/// This may include optional `details` like field errors or custom codes.
class ClientException extends ApiException {
  const ClientException({
    required String message,
    Map<String, dynamic>? details,
    ApiErrorCode errorCode = ApiErrorCode.badRequest,
  }) : super(message: message, errorCode: errorCode, details: details);
}

class ResourceNotFoundException extends ClientException {
  const ResourceNotFoundException({
    String message = "Resource Not found",
    Map<String, dynamic>? details,
  }) : super(
         message: message,
         errorCode: ApiErrorCode.notFound,
         details: details,
       );
}

/// Thrown for server-side errors like 500 internal errors.
class ServerException extends ApiException {
  const ServerException(String message)
    : super(message: message, errorCode: ApiErrorCode.internalServerError);
}

/// Thrown when the status code doesn't match expected values (e.g., 300, 418).
class UnexpectedStatusCodeException extends ApiException {
  const UnexpectedStatusCodeException(String message)
    : super(message: message, errorCode: ApiErrorCode.unknown);
}
