import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/admin_attendance_record.dart';
import '../entities/qr_session.dart';

abstract class AdminRepository {
  /// Invokes the `create_attendance_session` RPC to start a new QR session with optional custom duration.
  Future<Result<QrSession, Failure>> createQrSession({int? durationMinutes});

  /// Queries all employee attendance records with joined employee metadata.
  /// Supports offset-based pagination and optional work date / name filtering.
  Future<Result<List<AdminAttendanceRecord>, Failure>> getAllAttendanceRecords({
    int offset = 0,
    int limit = 20,
    String? workDate,
    String? query,
  });
}

