import 'package:equatable/equatable.dart';

/// Domain entity representing an attendance record joined with employee profile details.
class AdminAttendanceRecord extends Equatable {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String workDate;
  final DateTime? checkInAt;
  final double? checkInLat;
  final double? checkInLng;
  final DateTime? checkOutAt;
  final double? checkOutLat;
  final double? checkOutLng;
  final DateTime? createdAt;

  const AdminAttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.workDate,
    this.checkInAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutAt,
    this.checkOutLat,
    this.checkOutLng,
    this.createdAt,
  });

  bool get isCompleted => checkInAt != null && checkOutAt != null;
  bool get isCheckedInOnly => checkInAt != null && checkOutAt == null;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeCode,
        employeeName,
        workDate,
        checkInAt,
        checkInLat,
        checkInLng,
        checkOutAt,
        checkOutLat,
        checkOutLng,
        createdAt,
      ];
}

