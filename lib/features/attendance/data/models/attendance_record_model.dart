import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.employeeId,
    required super.workDate,
    super.checkInAt,
    super.checkInLat,
    super.checkInLng,
    super.checkInSessionId,
    super.checkOutAt,
    super.checkOutLat,
    super.checkOutLng,
    super.checkOutSessionId,
    super.createdAt,
  });

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) {
    return AttendanceRecordModel(
      id: entity.id,
      employeeId: entity.employeeId,
      workDate: entity.workDate,
      checkInAt: entity.checkInAt,
      checkInLat: entity.checkInLat,
      checkInLng: entity.checkInLng,
      checkInSessionId: entity.checkInSessionId,
      checkOutAt: entity.checkOutAt,
      checkOutLat: entity.checkOutLat,
      checkOutLng: entity.checkOutLng,
      checkOutSessionId: entity.checkOutSessionId,
      createdAt: entity.createdAt,
    );
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      workDate: json['work_date']?.toString() ?? '',
      checkInAt: json['check_in_at'] != null ? DateTime.tryParse(json['check_in_at'].toString()) : null,
      checkInLat: json['check_in_lat'] != null ? (json['check_in_lat'] as num).toDouble() : null,
      checkInLng: json['check_in_lng'] != null ? (json['check_in_lng'] as num).toDouble() : null,
      checkInSessionId: json['check_in_session_id']?.toString(),
      checkOutAt: json['check_out_at'] != null ? DateTime.tryParse(json['check_out_at'].toString()) : null,
      checkOutLat: json['check_out_lat'] != null ? (json['check_out_lat'] as num).toDouble() : null,
      checkOutLng: json['check_out_lng'] != null ? (json['check_out_lng'] as num).toDouble() : null,
      checkOutSessionId: json['check_out_session_id']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'work_date': workDate,
      if (checkInAt != null) 'check_in_at': checkInAt!.toIso8601String(),
      if (checkInLat != null) 'check_in_lat': checkInLat,
      if (checkInLng != null) 'check_in_lng': checkInLng,
      if (checkInSessionId != null) 'check_in_session_id': checkInSessionId,
      if (checkOutAt != null) 'check_out_at': checkOutAt!.toIso8601String(),
      if (checkOutLat != null) 'check_out_lat': checkOutLat,
      if (checkOutLng != null) 'check_out_lng': checkOutLng,
      if (checkOutSessionId != null) 'check_out_session_id': checkOutSessionId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory AttendanceRecordModel.fromDb(Map<String, dynamic> map) {
    return AttendanceRecordModel(
      id: map['id']?.toString() ?? '',
      employeeId: map['employee_id']?.toString() ?? '',
      workDate: map['work_date']?.toString() ?? '',
      checkInAt: map['check_in_at'] != null ? DateTime.tryParse(map['check_in_at'].toString()) : null,
      checkInLat: map['check_in_lat'] != null ? (map['check_in_lat'] as num).toDouble() : null,
      checkInLng: map['check_in_lng'] != null ? (map['check_in_lng'] as num).toDouble() : null,
      checkInSessionId: null, // SQLite table does not store session IDs
      checkOutAt: map['check_out_at'] != null ? DateTime.tryParse(map['check_out_at'].toString()) : null,
      checkOutLat: map['check_out_lat'] != null ? (map['check_out_lat'] as num).toDouble() : null,
      checkOutLng: map['check_out_lng'] != null ? (map['check_out_lng'] as num).toDouble() : null,
      checkOutSessionId: null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'employee_id': employeeId,
      'work_date': workDate,
      'check_in_at': checkInAt?.toIso8601String(),
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_out_at': checkOutAt?.toIso8601String(),
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AttendanceRecordModel copyWith({
    String? id,
    String? employeeId,
    String? workDate,
    DateTime? checkInAt,
    double? checkInLat,
    double? checkInLng,
    String? checkInSessionId,
    DateTime? checkOutAt,
    double? checkOutLat,
    double? checkOutLng,
    String? checkOutSessionId,
    DateTime? createdAt,
  }) {
    return AttendanceRecordModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      workDate: workDate ?? this.workDate,
      checkInAt: checkInAt ?? this.checkInAt,
      checkInLat: checkInLat ?? this.checkInLat,
      checkInLng: checkInLng ?? this.checkInLng,
      checkInSessionId: checkInSessionId ?? this.checkInSessionId,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      checkOutLat: checkOutLat ?? this.checkOutLat,
      checkOutLng: checkOutLng ?? this.checkOutLng,
      checkOutSessionId: checkOutSessionId ?? this.checkOutSessionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

