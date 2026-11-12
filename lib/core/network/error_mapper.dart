import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';

/// Centralized mapper that converts DioExceptions, HTTP statuses, and Supabase RPC codes
/// into strongly-typed domain Failure instances.
class ErrorMapper {
  const ErrorMapper._();

  static Failure map(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is QrInvalidException) {
      return QrInvalidFailure(error.message);
    }

    if (error is LocationException) {
      return LocationFailure(error.message);
    }

    if (error is CacheException) {
      return CacheFailure(error.message);
    }

    if (error is! DioException) {
      return ServerFailure(error.toString());
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        // Extract error message or code from Supabase response payload
        String rawMessage = '';
        if (data is Map<String, dynamic>) {
          rawMessage = (data['message'] ??
                  data['error_description'] ??
                  data['error'] ??
                  data['msg'] ??
                  '')
              .toString();
        } else if (data is String) {
          rawMessage = data;
        }

        final upperMsg = rawMessage.toUpperCase();

        // 1. Supabase RPC Domain Error Codes
        if (upperMsg.contains('QR_EXPIRED')) {
          return const QrExpiredFailure();
        }
        if (upperMsg.contains('QR_INVALID')) {
          return const QrInvalidFailure();
        }
        if (upperMsg.contains('SESSION_REUSED')) {
          return const SessionReusedFailure();
        }
        if (upperMsg.contains('ALREADY_COMPLETED')) {
          return const DuplicateAttendanceFailure();
        }
        if (upperMsg.contains('LOCATION_REQUIRED')) {
          return const LocationFailure('Valid GPS coordinates are required to mark attendance.');
        }
        if (upperMsg.contains('FORBIDDEN')) {
          return const ForbiddenFailure();
        }
        if (upperMsg.contains('UNAUTHORIZED')) {
          return const UnauthorizedFailure();
        }

        // 2. HTTP Status Code Mapping
        if (statusCode == 400) {
          if (rawMessage.toLowerCase().contains('invalid login credentials') ||
              rawMessage.toLowerCase().contains('invalid_grant')) {
            return const UnauthorizedFailure('Invalid email or password.');
          }
          return ServerFailure(rawMessage.isNotEmpty ? rawMessage : 'Bad request.');
        }

        if (statusCode == 401) {
          return const UnauthorizedFailure();
        }

        if (statusCode == 403) {
          return const ForbiddenFailure();
        }

        if (statusCode != null && statusCode >= 500) {
          return const ServerFailure();
        }

        return ServerFailure(rawMessage.isNotEmpty ? rawMessage : 'Unexpected server response ($statusCode)');

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');

      case DioExceptionType.unknown:
      default:
        final message = error.message ?? '';
        if (message.contains('SocketException') || message.contains('HandshakeException')) {
          return const NetworkFailure();
        }
        return ServerFailure(message.isNotEmpty ? message : 'An unexpected error occurred.');
    }
  }
}

