import '../../domain/entities/employee_profile.dart';
import '../../domain/entities/user_role.dart';

class EmployeeProfileModel extends EmployeeProfile {
  const EmployeeProfileModel({
    required super.id,
    required super.employeeCode,
    required super.name,
    required super.email,
    required super.role,
    super.createdAt,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'] as String,
      employeeCode: json['employee_code'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'name': name,
      'email': email,
      'role': role.toDbString(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory EmployeeProfileModel.fromEntity(EmployeeProfile entity) {
    return EmployeeProfileModel(
      id: entity.id,
      employeeCode: entity.employeeCode,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      createdAt: entity.createdAt,
    );
  }
}

