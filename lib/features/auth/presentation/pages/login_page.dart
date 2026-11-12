export 'admin_login_page.dart';
export 'employee_login_page.dart';
export 'splash_page.dart';

import 'package:flutter/material.dart';
import 'employee_login_page.dart';

/// Default Login screen routing to the Employee portal by default,
/// with the integrated top pill switcher to toggle to Admin portal.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmployeeLoginPage();
  }
}
