import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _credentialsError = false;
  bool _passwordHasError = false;
  String? _emailErrorText;

  bool get _hasErrorState =>
      _credentialsError || _passwordHasError || _emailErrorText != null;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  void _onEmailChanged(String val) {
    setState(() {
      _credentialsError = false;
      _passwordHasError = false;

      if (val.trim().isEmpty) {
        _emailErrorText = 'Please enter your email';
      } else if (!_isValidEmail(val)) {
        _emailErrorText = 'Please enter a valid email address';
      } else {
        _emailErrorText = null;
      }
    });
  }

  void _onPasswordChanged(String val) {
    if (_hasErrorState) {
      setState(() {
        _credentialsError = false;
        _passwordHasError = false;

        final email = _emailController.text.trim();
        if (email.isEmpty) {
          _emailErrorText = 'Please enter your email';
        } else if (!_isValidEmail(email)) {
          _emailErrorText = 'Please enter a valid email address';
        } else {
          _emailErrorText = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;

    if (email.isEmpty) {
      _emailErrorText = 'Please enter your email';
      hasError = true;
    } else if (!_isValidEmail(email)) {
      _emailErrorText = 'Please enter a valid email address';
      hasError = true;
    } else {
      _emailErrorText = null;
    }

    if (password.isEmpty) {
      _passwordHasError = true;
      hasError = true;
    } else {
      _passwordHasError = false;
    }

    if (hasError) {
      setState(() {
        _credentialsError = false;
      });
      return;
    }

    setState(() {
      _credentialsError = false;
    });

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          LoginSubmitted(
            email: email,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 440.w),
              child: BlocConsumer<AuthBloc, AuthState>(
                listenWhen: (previous, current) => current is AuthError && previous != current,
                listener: (context, state) {
                  if (state is AuthError) {
                    setState(() {
                      _credentialsError = true;
                      _emailErrorText = null;
                      _passwordHasError = false;
                    });
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20.r),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                state.message,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.statusError,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand Icon
                      Center(
                        child: Container(
                          width: 68.r,
                          height: 68.r,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: Offset(0, 6.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 34.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      Text(
                        'MarkMe Employee',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Sign in to scan attendance, view status & history',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // Login Card
                      Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppTheme.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: Offset(0, 8.h),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Employee Sign In',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Enter your employee email and password',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Email Field
                              Text(
                                'Work Email',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                onChanged: _onEmailChanged,
                                decoration: InputDecoration(
                                  hintText: 'user1@mail.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.textMuted,
                                    size: 20.r,
                                  ),
                                  errorText: _emailErrorText,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: (_credentialsError || _emailErrorText != null)
                                          ? AppTheme.statusError
                                          : AppTheme.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: (_credentialsError || _emailErrorText != null)
                                          ? AppTheme.statusError
                                          : AppTheme.primaryLight,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 18.h),

                              // Password Field
                              Text(
                                'Password',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                onChanged: _onPasswordChanged,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: '••••••••••••',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppTheme.textMuted,
                                    size: 20.r,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppTheme.textMuted,
                                      size: 20.r,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: (_passwordHasError || _credentialsError)
                                          ? AppTheme.statusError
                                          : AppTheme.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: (_passwordHasError || _credentialsError)
                                          ? AppTheme.statusError
                                          : AppTheme.primaryLight,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Submit Button
                              FilledButton(
                                onPressed: isLoading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20.r,
                                        width: 20.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Sign In to Employee Portal',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Switch to Admin Portal Button
                      OutlinedButton.icon(
                        icon: Icon(Icons.admin_panel_settings_rounded, size: 18.r),
                        label: Text(
                          'Switch to Admin Portal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () => context.go('/login/admin'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

