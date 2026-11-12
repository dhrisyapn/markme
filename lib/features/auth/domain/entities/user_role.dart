/// Role discriminator for authorization and routing.
enum UserRole {
  admin,
  employee;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  String toDbString() => name;

  bool get isAdmin => this == UserRole.admin;
  bool get isEmployee => this == UserRole.employee;
}

