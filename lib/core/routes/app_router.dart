import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/qr_session_page.dart';
import '../../features/attendance/presentation/pages/employee_home_page.dart';
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
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == '/login';

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

        // Role-based protection
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
        path: '/login',
        builder: (context, state) => const LoginPage(),
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
    ],
  );
}

