import '../../domain/entities/admin_attendance_record.dart';

class AdminAttendanceRecordModel extends AdminAttendanceRecord {
  const AdminAttendanceRecordModel({
    required super.id,
    required super.employeeId,
    required super.employeeCode,
    required super.employeeName,
    required super.workDate,
    super.checkInAt,
    super.checkInLat,
    super.checkInLng,
    super.checkOutAt,
    super.checkOutLat,
    super.checkOutLng,
    super.createdAt,
  });

  factory AdminAttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    String empCode = '--';
    String empName = 'Unknown Employee';

    final empData = json['employees'];
    if (empData is Map<String, dynamic>) {
      empCode = empData['employee_code'] as String? ?? '--';
      empName = empData['name'] as String? ?? 'Unknown Employee';
    }

    return AdminAttendanceRecordModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      employeeCode: empCode,
      employeeName: empName,
      workDate: json['work_date'] as String,
      checkInAt: json['check_in_at'] != null
          ? DateTime.tryParse(json['check_in_at'] as String)
          : null,
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkOutAt: json['check_out_at'] != null
          ? DateTime.tryParse(json['check_out_at'] as String)
          : null,
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

