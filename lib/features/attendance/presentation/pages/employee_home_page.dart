import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../widgets/location_service_dialog.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage>
    with WidgetsBindingObserver {
  String? _employeeId;
  bool _isLocationDialogOpen = false;
  StreamSubscription<ServiceStatus>? _locationStatusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTodayStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationService();
    });
    _listenToLocationStatus();
  }

  @override
  void dispose() {
    _locationStatusSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkLocationService();
    }
  }

  Future<void> _checkLocationService() async {
    try {
      final locationService = sl<LocationService>();
      final isEnabled = await locationService.isLocationServiceEnabled();
      if (!mounted) return;

      if (!isEnabled) {
        _showLocationDialog();
      } else {
        _dismissLocationDialog();
      }
    } catch (_) {
      // Platform exception fallback
    }
  }

  void _listenToLocationStatus() {
    try {
      final locationService = sl<LocationService>();
      _locationStatusSubscription =
          locationService.getServiceStatusStream().listen((status) {
        if (!mounted) return;
        if (status == ServiceStatus.enabled) {
          _dismissLocationDialog();
        } else if (status == ServiceStatus.disabled) {
          _showLocationDialog();
        }
      });
    } catch (_) {
      // Ignored if service status stream unavailable
    }
  }

  void _showLocationDialog() {
    if (_isLocationDialogOpen || !mounted) return;
    _isLocationDialogOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LocationServiceDialog(
        onOpenSettings: () async {
          final locationService = sl<LocationService>();
          await locationService.openLocationSettings();
        },
      ),
    ).then((_) {
      _isLocationDialogOpen = false;
    });
  }

  void _dismissLocationDialog() {
    if (_isLocationDialogOpen && mounted) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
      }
      _isLocationDialogOpen = false;
    }
  }

  void _loadTodayStatus() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _employeeId = authState.profile.id;
      context.read<AttendanceBloc>().add(TodayStatusRequested(_employeeId!));
    }
  }

  Future<void> _navigateToScanner() async {
    final result = await context.push<bool>('/employee/scan');
    if (result == true && mounted) {
      _loadTodayStatus();
    }
  }

  void _confirmSignOut() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of MarkMe?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.statusError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryBlue, size: 20.r),
            ),
            SizedBox(width: 10.w),
            Text(
              'MarkMe',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: Icon(Icons.logout_rounded, size: 22.r, color: AppTheme.textSecondary),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadTodayStatus(),
          color: AppTheme.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String employeeName = 'Employee';
                String employeeCode = 'EMP---';
                String employeeEmail = '';

                if (authState is Authenticated) {
                  employeeName = authState.profile.name;
                  employeeCode = authState.profile.employeeCode;
                  employeeEmail = authState.profile.email;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    _buildProfileHeader(
                      name: employeeName,
                      code: employeeCode,
                      email: employeeEmail,
                    ),
                    SizedBox(height: 20.h),

                    // Today Status Card
                    BlocBuilder<AttendanceBloc, AttendanceState>(
                      builder: (context, attState) {
                        AttendanceRecord? todayRecord;
                        bool isLoading = false;

                        if (attState is AttendanceLoading) {
                          isLoading = true;
                        } else if (attState is TodayStatusLoaded) {
                          todayRecord = attState.record;
                        } else if (attState is AttendanceSuccess) {
                          todayRecord = attState.record;
                        }

                        final isCompleted = todayRecord?.isCompleted ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTodayStatusCard(
                              record: todayRecord,
                              isLoading: isLoading,
                            ),
                            if (!isCompleted) ...[
                              SizedBox(height: 24.h),

                              // Dynamic Scan Action Button
                              _buildScanActionButton(
                                record: todayRecord,
                                isLoading: isLoading,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Quick Nav: View History Card
                    _buildQuickActionCard(
                      icon: Icons.history_edu_rounded,
                      title: 'My Attendance History',
                      subtitle: 'Review past attendance logs, GPS locations, and hours',
                      onTap: () => context.push('/employee/history'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String code,
    required String email,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppTheme.primarySurface,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'E',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    code,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatusCard({
    required AttendanceRecord? record,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const TodayAttendanceCardShimmer();
    }

    final bool isCompleted = record?.isCompleted ?? false;
    final bool isCheckedIn = record?.isCheckedIn ?? false;

    Color badgeBg;
    Color badgeText;
    String statusTitle;
    String statusSubtitle;
    IconData statusIcon;

    if (isCompleted) {
      badgeBg = AppTheme.statusSuccessSurface;
      badgeText = AppTheme.statusSuccess;
      statusTitle = 'Completed for Today';
      statusSubtitle = 'Both check-in and check-out recorded';
      statusIcon = Icons.check_circle_rounded;
    } else if (isCheckedIn) {
      badgeBg = AppTheme.statusWarningSurface;
      badgeText = AppTheme.statusWarning;
      statusTitle = 'Checked In';
      statusSubtitle = 'Scan active session to check out';
      statusIcon = Icons.how_to_reg_rounded;
    } else {
      badgeBg = AppTheme.primarySurface;
      badgeText = AppTheme.primaryBlue;
      statusTitle = 'Not Checked In';
      statusSubtitle = 'Scan admin QR to mark arrival';
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Today\'s Attendance',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                DateFormatter.formatDisplayDate(DateTime.now()),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Status Badge Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: badgeText.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: badgeText, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: badgeText,
                        ),
                      ),
                      Text(
                        statusSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Check In / Check Out Grid
          Row(
            children: [
              // Check In Box
              Expanded(
                child: _buildTimeMetricBox(
                  title: 'Check-In',
                  time: record?.checkInAt != null ? DateFormatter.formatTime(record!.checkInAt) : '--:--',
                  coords: record?.checkInLat != null
                      ? '${record!.checkInLat!.toStringAsFixed(2)}, ${record.checkInLng!.toStringAsFixed(2)}'
                      : null,
                  isActive: isCheckedIn || isCompleted,
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
              SizedBox(width: 12.w),
              // Check Out Box
              Expanded(
                child: _buildTimeMetricBox(
                  title: 'Check-Out',
                  time: record?.checkOutAt != null ? DateFormatter.formatTime(record!.checkOutAt) : '--:--',
                  coords: record?.checkOutLat != null
                      ? '${record!.checkOutLat!.toStringAsFixed(2)}, ${record.checkOutLng!.toStringAsFixed(2)}'
                      : null,
                  isActive: isCompleted,
                  activeColor: AppTheme.statusSuccess,
                ),
              ),
            ],
          ),

          // Duration text if checked out
          if (isCompleted && record?.duration != null) ...[
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Work Duration: ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  DateFormatter.formatDuration(record!.checkInAt, record.checkOutAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeMetricBox({
    required String title,
    required String time,
    required String? coords,
    required bool isActive,
    required Color activeColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.3) : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
          ),
          if (coords != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 10.r, color: AppTheme.textMuted),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    coords,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanActionButton({
    required AttendanceRecord? record,
    required bool isLoading,
  }) {
    if (isLoading) {
      return AppShimmer(
        child: ShimmerBox(
          height: 56.h,
          borderRadius: 16.r,
        ),
      );
    }

    final bool isCompleted = record?.isCompleted ?? false;
    if (isCompleted) {
      return const SizedBox.shrink();
    }

    final bool isCheckedIn = record?.isCheckedIn ?? false;
    final String buttonLabel = isCheckedIn ? 'Scan QR to Check Out' : 'Scan QR to Check In';
    final IconData buttonIcon = isCheckedIn ? Icons.logout_rounded : Icons.qr_code_scanner_rounded;
    final Color buttonColor = isCheckedIn ? AppTheme.statusWarning : AppTheme.primaryBlue;

    return FilledButton(
      onPressed: isLoading ? null : _navigateToScanner,
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            buttonIcon,
            size: 22.r,
            color: Colors.white,
          ),
          SizedBox(width: 10.w),
          Text(
            buttonLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20.r),
          ],
        ),
      ),
    );
  }
}
