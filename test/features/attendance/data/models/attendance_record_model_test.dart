import 'package:flutter_test/flutter_test.dart';
import 'package:markme/features/attendance/data/models/attendance_record_model.dart';

void main() {
  group('AttendanceRecordModel', () {
    final tModel = AttendanceRecordModel(
      id: 'rec-001',
      employeeId: 'emp-001',
      workDate: '2026-11-12',
      checkInAt: DateTime.parse('2026-11-12T09:00:00Z'),
      checkInLat: 12.9716,
      checkInLng: 77.5946,
      checkInSessionId: 'sess-001',
      checkOutAt: DateTime.parse('2026-11-12T17:30:00Z'),
      checkOutLat: 12.9717,
      checkOutLng: 77.5947,
      checkOutSessionId: 'sess-002',
      createdAt: DateTime.parse('2026-11-12T09:00:00Z'),
    );

    test('serializes to and from JSON correctly', () {
      final json = tModel.toJson();
      final fromJson = AttendanceRecordModel.fromJson(json);

      expect(fromJson.id, tModel.id);
      expect(fromJson.employeeId, tModel.employeeId);
      expect(fromJson.workDate, tModel.workDate);
      expect(fromJson.checkInLat, tModel.checkInLat);
      expect(fromJson.isCompleted, true);
      expect(fromJson.duration, const Duration(hours: 8, minutes: 30));
    });

    test('serializes to and from SQLite map correctly', () {
      final dbMap = tModel.toDb();
      final fromDb = AttendanceRecordModel.fromDb(dbMap);

      expect(fromDb.id, tModel.id);
      expect(fromDb.employeeId, tModel.employeeId);
      expect(fromDb.workDate, tModel.workDate);
      expect(fromDb.checkInLat, tModel.checkInLat);
      expect(fromDb.checkOutLat, tModel.checkOutLat);
      expect(fromDb.isCompleted, true);
    });

    test('correctly identifies check-in vs completed states', () {
      final inProgress = AttendanceRecordModel(
        id: tModel.id,
        employeeId: tModel.employeeId,
        workDate: tModel.workDate,
        checkInAt: tModel.checkInAt,
        checkInLat: tModel.checkInLat,
        checkInLng: tModel.checkInLng,
        checkOutAt: null,
      );
      expect(inProgress.isCheckedIn, true);
      expect(inProgress.isCompleted, false);
      expect(inProgress.duration, null);
    });
  });
}
