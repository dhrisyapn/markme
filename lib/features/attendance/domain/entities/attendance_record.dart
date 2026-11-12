import 'package:equatable/equatable.dart';

/// Represents a daily attendance record for an employee.
class AttendanceRecord extends Equatable {
  final String id;
  final String employeeId;
  final String workDate;
  final DateTime? checkInAt;
  final double? checkInLat;
  final double? checkInLng;
  final String? checkInSessionId;
  final DateTime? checkOutAt;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkOutSessionId;
  final DateTime? createdAt;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.workDate,
    this.checkInAt,
    this.checkInLat,
    this.checkInLng,
    this.checkInSessionId,
    this.checkOutAt,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutSessionId,
    this.createdAt,
  });

  /// True when employee has recorded both check-in and check-out today.
  bool get isCompleted => checkInAt != null && checkOutAt != null;

  /// True when employee has checked in but has not yet checked out.
  bool get isCheckedIn => checkInAt != null && checkOutAt == null;

  /// Returns total working duration if both check-in and check-out exist.
  Duration? get duration {
    if (checkInAt != null && checkOutAt != null) {
      final diff = checkOutAt!.difference(checkInAt!);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        workDate,
        checkInAt,
        checkInLat,
        checkInLng,
        checkInSessionId,
        checkOutAt,
        checkOutLat,
        checkOutLng,
        checkOutSessionId,
        createdAt,
      ];
}

