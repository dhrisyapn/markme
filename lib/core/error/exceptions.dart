/// Base class for data source exceptions thrown before mapping to domain Failures.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AppException(message: $message, statusCode: $statusCode)';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.details});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode, super.details});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No network connection available', dynamic details])
      : super(details: details);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache read or write operation failed', dynamic details])
      : super(details: details);
}

class LocationException extends AppException {
  const LocationException(super.message);
}
