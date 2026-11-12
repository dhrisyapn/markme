import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/admin_attendance_record.dart';
import '../../domain/entities/qr_session.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  const AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<QrSession, Failure>> createQrSession({int? durationMinutes}) async {
    try {
      final session = await _remoteDataSource.createQrSession(durationMinutes: durationMinutes);
      return Success(session);
    } catch (e) {
      return ErrorResult(ErrorMapper.map(e));
    }
  }

  @override
  Future<Result<List<AdminAttendanceRecord>, Failure>> getAllAttendanceRecords({
    int offset = 0,
    int limit = 20,
    String? workDate,
    String? query,
  }) async {
    try {
      final records = await _remoteDataSource.getAllAttendanceRecords(
        offset: offset,
        limit: limit,
        workDate: workDate,
      );

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final filtered = records.where((r) {
          return r.employeeName.toLowerCase().contains(q) ||
              r.employeeCode.toLowerCase().contains(q);
        }).toList();
        return Success(filtered);
      }

      return Success(records);
    } catch (e) {
      return ErrorResult(ErrorMapper.map(e));
    }
  }
}

