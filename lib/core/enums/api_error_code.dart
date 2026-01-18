/// Enum representing various API error codes.
enum ApiErrorCode {
  badRequest, // 400
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  conflict, // 409
  internalServerError, // 500
  networkError,
  parsingError,
  validationError,
  unknown,
}
