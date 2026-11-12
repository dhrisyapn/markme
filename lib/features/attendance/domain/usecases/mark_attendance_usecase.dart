import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/attendance_action.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendanceUseCase {
  final AttendanceRepository repository;

  const MarkAttendanceUseCase(this.repository);

  Future<Result<({AttendanceAction action, AttendanceRecord record}), Failure>> call({
    required String sessionId,
    required String token,
    required double lat,
    required double lng,
  }) {
    return repository.markAttendance(
      sessionId: sessionId,
      token: token,
      lat: lat,
      lng: lng,
    );
  }
}

