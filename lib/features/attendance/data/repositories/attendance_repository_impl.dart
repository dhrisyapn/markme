import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/attendance_action.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;

  const AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<AttendanceRecord?, Failure>> getTodayStatus(String employeeId) async {
    final todayUtc = DateFormatter.todayUtcString();

    try {
      final remoteRecord = await remoteDataSource.getTodayRecord(employeeId, todayUtc);
      if (remoteRecord != null) {
        await localDataSource.upsertRecord(remoteRecord);
        return Success(remoteRecord);
      } else {
        // No record today on remote
        return const Success(null);
      }
    } catch (e) {
      // If remote query fails (e.g. offline), try local cache
      try {
        final cached = await localDataSource.getTodayRecord(employeeId, todayUtc);
        return Success(cached);
      } catch (_) {
        return ErrorResult(ErrorMapper.map(e));
      }
    }
  }

  @override
  Future<Result<({AttendanceAction action, AttendanceRecord record}), Failure>> markAttendance({
    required String sessionId,
    required String token,
    required double lat,
    required double lng,
  }) async {
    try {
      final result = await remoteDataSource.markAttendance(
        sessionId: sessionId,
        token: token,
        lat: lat,
        lng: lng,
      );

      // Cache the authoritative record in local SQLite database
      await localDataSource.upsertRecord(result.record);

      return Success((action: result.action, record: result.record));
    } catch (e) {
      return ErrorResult(ErrorMapper.map(e));
    }
  }

  @override
  Future<Result<List<AttendanceRecord>, Failure>> getAttendanceHistory(
    String employeeId, {
    bool forceRefresh = false,
  }) async {
    try {
      final remoteRecords = await remoteDataSource.getMyHistory(employeeId);
      if (remoteRecords.isNotEmpty) {
        await localDataSource.upsertRecordsBatch(remoteRecords);
      }
      return Success(remoteRecords);
    } catch (e) {
      // Remote call failed (offline or network error) -> attempt offline fallback from SQLite
      try {
        final localRecords = await localDataSource.getAllRecords(employeeId);
        if (localRecords.isNotEmpty) {
          return Success(localRecords);
        }
      } catch (_) {}
      return ErrorResult(ErrorMapper.map(e));
    }
  }
}

