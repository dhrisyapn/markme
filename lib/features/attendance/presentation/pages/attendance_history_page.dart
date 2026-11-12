import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _employeeId = authState.profile.id;
      context.read<HistoryBloc>().add(
            HistoryRequested(employeeId: _employeeId!),
          );
    }
  }

  Future<void> _refresh() async {
    if (_employeeId != null) {
      final historyBloc = context.read<HistoryBloc>();
      final nextState = historyBloc.stream.first;
      historyBloc.add(
        HistoryRefreshed(employeeId: _employeeId!),
      );
      await nextState;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 22.r, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const HistoryPageShimmer();
          }

          if (state is HistoryError && (state.cachedRecords == null || state.cachedRecords!.isEmpty)) {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ErrorView(
                    message: state.message,
                    onRetry: _refresh,
                  ),
                ),
              ),
            );
          }

          final records = state is HistoryLoaded
              ? state.records
              : (state is HistoryError ? state.cachedRecords ?? [] : <AttendanceRecord>[]);

          final isOffline = (state is HistoryLoaded && state.isOffline) || state is HistoryError;

          if (records.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmptyState(),
                ),
              ),
            );
          }

          final completedCount = records.where((r) => r.isCompleted).length;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppTheme.primaryBlue,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // Offline notice banner if running offline
                if (isOffline) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppTheme.statusWarningSurface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.statusWarning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: AppTheme.statusWarning, size: 18.r),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Offline Mode: Displaying cached attendance records.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Metrics Summary Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildMetricItem(
                        label: 'Total Logs',
                        value: '${records.length}',
                        icon: Icons.calendar_month_rounded,
                        color: AppTheme.primaryBlue,
                      ),
                      Container(
                        height: 36.h,
                        width: 1.w,
                        color: AppTheme.borderLight,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      _buildMetricItem(
                        label: 'Completed',
                        value: '$completedCount',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppTheme.statusSuccess,
                      ),
                      Container(
                        height: 36.h,
                        width: 1.w,
                        color: AppTheme.borderLight,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      _buildMetricItem(
                        label: 'Incomplete',
                        value: '${records.length - completedCount}',
                        icon: Icons.timelapse_rounded,
                        color: AppTheme.statusWarning,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Records Header
                Text(
                  'Past Attendance Records',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),

                // Attendance Cards List
                ...records.map((record) => _buildRecordCard(record)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.r, color: color),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(AttendanceRecord record) {
    final isCompleted = record.isCompleted;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16.r, color: AppTheme.primaryBlue),
                  SizedBox(width: 8.w),
                  Text(
                    DateFormatter.formatDisplayDate(record.workDate),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              _buildStatusPill(isCompleted),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: AppTheme.borderLight),
          SizedBox(height: 12.h),

          // Check-in and Check-out details
          Row(
            children: [
              // Check In
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECK IN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormatter.formatTime(record.checkInAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (record.checkInLat != null) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12.r, color: AppTheme.textMuted),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              '${record.checkInLat!.toStringAsFixed(3)}, ${record.checkInLng!.toStringAsFixed(3)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow / Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Icon(Icons.arrow_forward_rounded, size: 18.r, color: AppTheme.borderLight),
              ),

              // Check Out
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECK OUT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      record.checkOutAt != null
                          ? DateFormatter.formatTime(record.checkOutAt)
                          : '--:--',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: record.checkOutAt != null ? AppTheme.textPrimary : AppTheme.textMuted,
                      ),
                    ),
                    if (record.checkOutLat != null) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12.r, color: AppTheme.textMuted),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              '${record.checkOutLat!.toStringAsFixed(3)}, ${record.checkOutLng!.toStringAsFixed(3)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Total duration row if completed
          if (record.duration != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.timelapse_rounded, size: 14.r, color: AppTheme.primaryBlue),
                  SizedBox(width: 6.w),
                  Text(
                    'Work Duration:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    DateFormatter.formatDuration(record.checkInAt, record.checkOutAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPill(bool isCompleted) {
    final bgColor = isCompleted ? AppTheme.statusSuccessSurface : AppTheme.statusWarningSurface;
    final textColor = isCompleted ? AppTheme.statusSuccess : AppTheme.statusWarning;
    final label = isCompleted ? 'Completed' : 'In Progress';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note_rounded,
                size: 40.r,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Records Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You have not recorded any attendance logs yet. Use the QR scanner on the home screen to check in.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

