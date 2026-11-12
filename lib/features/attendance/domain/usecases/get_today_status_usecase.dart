import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetTodayStatusUseCase {
  final AttendanceRepository repository;

  const GetTodayStatusUseCase(this.repository);

  Future<Result<AttendanceRecord?, Failure>> call(String employeeId) {
    return repository.getTodayStatus(employeeId);
  }
}

