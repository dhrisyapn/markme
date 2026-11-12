import '../../../../core/storage/app_database.dart';
import '../models/attendance_record_model.dart';

abstract class AttendanceLocalDataSource {
  Future<void> upsertRecord(AttendanceRecordModel record);
  Future<void> upsertRecordsBatch(List<AttendanceRecordModel> records);
  Future<AttendanceRecordModel?> getTodayRecord(String employeeId, String workDate);
  Future<List<AttendanceRecordModel>> getAllRecords(String employeeId);
  Future<void> clearAll();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final AppDatabase _database;

  const AttendanceLocalDataSourceImpl(this._database);

  @override
  Future<void> upsertRecord(AttendanceRecordModel record) async {
    await _database.upsertRecord(record.toDb());
  }

  @override
  Future<void> upsertRecordsBatch(List<AttendanceRecordModel> records) async {
    final batch = records.map((r) => r.toDb()).toList();
    await _database.upsertRecordsBatch(batch);
  }

  @override
  Future<AttendanceRecordModel?> getTodayRecord(String employeeId, String workDate) async {
    final row = await _database.getTodayRecord(employeeId, workDate);
    if (row != null) {
      return AttendanceRecordModel.fromDb(row);
    }
    return null;
  }

  @override
  Future<List<AttendanceRecordModel>> getAllRecords(String employeeId) async {
    final rows = await _database.getAllRecords(employeeId);
    return rows.map((r) => AttendanceRecordModel.fromDb(r)).toList();
  }

  @override
  Future<void> clearAll() async {
    await _database.clearAll();
  }
}

