import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/admin_attendance_record.dart';
import '../repositories/admin_repository.dart';

class GetAllAttendanceRecordsUseCase {
  final AdminRepository _repository;

  const GetAllAttendanceRecordsUseCase(this._repository);

  Future<Result<List<AdminAttendanceRecord>, Failure>> call({
    int offset = 0,
    int limit = 20,
    String? workDate,
    String? query,
  }) {
    return _repository.getAllAttendanceRecords(
      offset: offset,
      limit: limit,
      workDate: workDate,
      query: query,
    );
  }
}

