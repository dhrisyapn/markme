import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/qr_session_page.dart';
import '../../features/attendance/presentation/pages/attendance_history_page.dart';
import '../../features/attendance/presentation/pages/employee_home_page.dart';
import '../../features/attendance/presentation/pages/scan_qr_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation.startsWith('/login');
      final isSplash = state.matchedLocation == '/splash';

      // Allow SplashPage to display and manage initial verification navigation
      if (isSplash) {
        return null;
      }

      if (authState is AuthInitial || (authState is AuthLoading && authState.message?.contains('Checking') == true)) {
        return null;
      }

      if (authState is Unauthenticated || authState is AuthError) {
        return isLoggingIn ? null : '/login';
      }

      if (authState is Authenticated) {
        final profile = authState.profile;
        if (isLoggingIn) {
          return profile.isAdmin ? '/admin/dashboard' : '/employee/home';
        }

        // Role-based route protection
        if (!profile.isAdmin && state.matchedLocation.startsWith('/admin')) {
          return '/employee/home';
        }
        if (profile.isAdmin && state.matchedLocation.startsWith('/employee')) {
          return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) => '/login/employee',
      ),
      GoRoute(
        path: '/login/employee',
        builder: (context, state) => const EmployeeLoginPage(),
      ),
      GoRoute(
        path: '/login/admin',
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/qr-session',
        builder: (context, state) {
          final duration = state.extra as int?;
          return QrSessionPage(initialDurationMinutes: duration);
        },
      ),
      GoRoute(
        path: '/employee/home',
        builder: (context, state) => const EmployeeHomePage(),
      ),
      GoRoute(
        path: '/employee/scan',
        builder: (context, state) => const ScanQrPage(),
      ),
      GoRoute(
        path: '/employee/history',
        builder: (context, state) => const AttendanceHistoryPage(),
      ),
    ],
  );
}
