import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/attendance_action.dart';
import '../entities/attendance_record.dart';

/// Contract for attendance data retrieval and submission.
abstract class AttendanceRepository {
  /// Fetches today's attendance record for the employee from local/remote.
  Future<Result<AttendanceRecord?, Failure>> getTodayStatus(String employeeId);

  /// Submits an authoritative check-in or check-out scan to Supabase RPC.
  Future<Result<({AttendanceAction action, AttendanceRecord record}), Failure>> markAttendance({
    required String sessionId,
    required String token,
    required double lat,
    required double lng,
  });

  /// Retrieves employee's historical attendance records with offline-first caching.
  Future<Result<List<AttendanceRecord>, Failure>> getAttendanceHistory(
    String employeeId, {
    bool forceRefresh = false,
  });
}

