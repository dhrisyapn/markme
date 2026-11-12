import 'package:equatable/equatable.dart';

/// Base sealed class for all domain-level failures across the application.
sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// No internet connection or low-level socket exception.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Request timed out (connect or receive timeout exceeded 15s).
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out. Please retry.']);
}

/// Unauthorized: 401 response, invalid credentials, or expired session.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Invalid credentials or session expired.']);
}

/// Forbidden: 403 response or role-based permission rejection.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You do not have permission to perform this action.']);
}

/// QR session has expired on the server (> 2 minutes).
class QrExpiredFailure extends Failure {
  const QrExpiredFailure([super.message = 'QR code has expired. Please ask the admin for a new one.']);
}

/// QR payload is malformed, unrecognized, or tampered with.
class QrInvalidFailure extends Failure {
  const QrInvalidFailure([super.message = 'Invalid or forged QR code.']);
}

/// Employee has already marked both check-in and check-out today.
class DuplicateAttendanceFailure extends Failure {
  const DuplicateAttendanceFailure([super.message = 'Attendance has already been completed for today.']);
}

/// Employee attempted to reuse the check-in QR session for check-out.
class SessionReusedFailure extends Failure {
  const SessionReusedFailure([super.message = 'Cannot reuse the same QR session for both check-in and check-out.']);
}

/// GPS location permission denied, service disabled, or coordinates unavailable.
class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

/// SQLite or secure storage local read/write error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage operation failed.']);
}

/// Unexpected 5xx server error or unhandled PostgREST exception.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server encountered an unexpected error. Please retry later.']);
}

