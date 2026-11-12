import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Application Splash Screen with centered branding (MarkMe title and Royal Blue QR logo).
/// Handles initial authentication session verification and role-based navigation.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthInitial) {
      authBloc.add(const AppStarted());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStateAndNavigate(authBloc.state);
    });
  }

  void _checkStateAndNavigate(AuthState state) {
    if (_hasNavigated || !mounted) return;

    final router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (state is Authenticated) {
      _hasNavigated = true;
      if (state.profile.isAdmin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/employee/home');
      }
    } else if (state is Unauthenticated || state is AuthError) {
      _hasNavigated = true;
      context.go('/login/employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _checkStateAndNavigate(state);
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Centered QR Brand Logo (matches sign in page style)
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 38.r,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 18.h),

                // App Name
                Text(
                  'MarkMe',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),

                // Subtitle
                Text(
                  'Smart QR Attendance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
