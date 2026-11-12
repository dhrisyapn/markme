import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Domain entity representing an authenticated employee or admin profile.
class EmployeeProfile extends Equatable {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  const EmployeeProfile({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role.isAdmin;

  @override
  List<Object?> get props => [id, employeeCode, name, email, role, createdAt];
}

