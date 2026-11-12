import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceHistoryUseCase {
  final AttendanceRepository repository;

  const GetAttendanceHistoryUseCase(this.repository);

  Future<Result<List<AttendanceRecord>, Failure>> call(
    String employeeId, {
    bool forceRefresh = false,
  }) {
    return repository.getAttendanceHistory(employeeId, forceRefresh: forceRefresh);
  }
}

