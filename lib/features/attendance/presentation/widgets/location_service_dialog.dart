import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// A non-dismissible dialog that informs the user to enable location services
/// and provides a single action button to open the device's location settings.
class LocationServiceDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const LocationServiceDialog({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Container(
          constraints: BoxConstraints(maxWidth: 380.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: AppTheme.statusWarningSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.location_off_rounded,
                    size: 32.r,
                    color: AppTheme.statusWarning,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Enable Location',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Explanation Message
              Text(
                'Location service is disabled on your device. Please turn on location in your device settings to use MarkMe and mark your attendance.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),

              // Single Action Button: Open Location Settings
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.settings_rounded, size: 20.r),
                  label: Text(
                    'Open Location Settings',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: onOpenSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
