import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/attendance_action.dart';
import '../../domain/entities/attendance_record.dart';

class ScanResultDialog extends StatelessWidget {
  final bool isSuccess;
  final AttendanceAction? action;
  final AttendanceRecord? record;
  final Failure? failure;
  final VoidCallback onDismiss;
  final VoidCallback? onRetry;

  const ScanResultDialog._({
    required this.isSuccess,
    this.action,
    this.record,
    this.failure,
    required this.onDismiss,
    this.onRetry,
  });

  factory ScanResultDialog.success({
    required AttendanceAction action,
    required AttendanceRecord record,
    required VoidCallback onDismiss,
  }) {
    return ScanResultDialog._(
      isSuccess: true,
      action: action,
      record: record,
      onDismiss: onDismiss,
    );
  }

  factory ScanResultDialog.failure({
    required Failure failure,
    required VoidCallback onDismiss,
    VoidCallback? onRetry,
  }) {
    return ScanResultDialog._(
      isSuccess: false,
      failure: failure,
      onDismiss: onDismiss,
      onRetry: onRetry,
    );
  }

  static Future<void> show({
    required BuildContext context,
    required bool isSuccess,
    AttendanceAction? action,
    AttendanceRecord? record,
    Failure? failure,
    required VoidCallback onDismiss,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => isSuccess
          ? ScanResultDialog.success(
              action: action ?? AttendanceAction.checkIn,
              record: record!,
              onDismiss: () {
                Navigator.of(ctx).pop();
                onDismiss();
              },
            )
          : ScanResultDialog.failure(
              failure: failure ?? const ServerFailure(),
              onDismiss: () {
                Navigator.of(ctx).pop();
                onDismiss();
              },
              onRetry: onRetry != null
                  ? () {
                      Navigator.of(ctx).pop();
                      onRetry();
                    }
                  : null,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400.w),
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon Circle
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: isSuccess ? AppTheme.statusSuccessSurface : AppTheme.statusErrorSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSuccess ? AppTheme.statusSuccess.withValues(alpha: 0.3) : AppTheme.statusError.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                size: 40.r,
                color: isSuccess ? AppTheme.statusSuccess : AppTheme.statusError,
              ),
            ),
            SizedBox(height: 20.h),

            // Header Title
            Text(
              isSuccess
                  ? '${action?.pastTense ?? "Attendance"} Successful!'
                  : _failureTitle(failure),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Description / Subtitle
            Text(
              isSuccess
                  ? 'Your attendance has been recorded and verified by the server.'
                  : (failure?.message ?? 'An unexpected error occurred while processing attendance.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),

            // Details Card for Success
            if (isSuccess && record != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Work Date',
                      value: DateFormatter.formatDisplayDate(record!.workDate),
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: action == AttendanceAction.checkOut ? 'Check-Out Time' : 'Check-In Time',
                      value: DateFormatter.formatTime(
                        action == AttendanceAction.checkOut ? record!.checkOutAt : record!.checkInAt,
                      ),
                    ),
                    if (action == AttendanceAction.checkOut && record!.duration != null) ...[
                      SizedBox(height: 12.h),
                      _buildDetailRow(
                        icon: Icons.timelapse_rounded,
                        label: 'Total Hours',
                        value: DateFormatter.formatDuration(record!.checkInAt, record!.checkOutAt),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'GPS Verified',
                      value: _formatCoords(
                        action == AttendanceAction.checkOut
                            ? (record!.checkOutLat ?? record!.checkInLat)
                            : record!.checkInLat,
                        action == AttendanceAction.checkOut
                            ? (record!.checkOutLng ?? record!.checkInLng)
                            : record!.checkInLng,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Action Buttons
            Row(
              children: [
                if (!isSuccess && onRetry != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRetry,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onDismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: isSuccess ? AppTheme.primaryBlue : AppTheme.textPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      isSuccess ? 'Done' : 'Close',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppTheme.primaryBlue),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatCoords(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Location Attached';
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  String _failureTitle(Failure? failure) {
    if (failure is QrExpiredFailure) return 'QR Code Expired';
    if (failure is QrInvalidFailure) return 'Invalid QR Code';
    if (failure is SessionReusedFailure) return 'Session Already Used';
    if (failure is DuplicateAttendanceFailure) return 'Attendance Already Marked';
    if (failure is LocationFailure) return 'Location Required';
    if (failure is NetworkFailure) return 'Connection Error';
    return 'Attendance Failed';
  }
}

