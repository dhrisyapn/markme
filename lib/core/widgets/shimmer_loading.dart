import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Base shimmer wrapper configuring the MarkMe design system slate-gradient colors.
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? const Color(0xFFE2E8F0),
      highlightColor: highlightColor ?? const Color(0xFFF8FAFC),
      child: child,
    );
  }
}

/// Generic rectangular shimmer placeholder block.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
      ),
    );
  }
}

/// Generic circular shimmer placeholder block.
class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Shimmer placeholder for Admin Dashboard Metrics row (Total Check-Ins, Completed Today).
class AdminMetricsRowShimmer extends StatelessWidget {
  const AdminMetricsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          Expanded(child: _buildMetricPlaceholder()),
          SizedBox(width: 12.w),
          Expanded(child: _buildMetricPlaceholder()),
        ],
      ),
    );
  }

  Widget _buildMetricPlaceholder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 36.r, height: 36.r, borderRadius: 12.r),
          SizedBox(height: 12.h),
          ShimmerBox(width: 40.w, height: 22.h, borderRadius: 4.r),
          SizedBox(height: 6.h),
          ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for a single Admin Attendance record card.
class AdminRecordCardShimmer extends StatelessWidget {
  const AdminRecordCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name/Date, Status Pill
          Row(
            children: [
              ShimmerCircle(size: 40.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 80.w, height: 11.h, borderRadius: 4.r),
                  ],
                ),
              ),
              ShimmerBox(width: 72.w, height: 24.h, borderRadius: 20.r),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: AppTheme.borderLight),
          SizedBox(height: 12.h),
          // Check-in and Check-out details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 50.w, height: 10.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 70.w, height: 14.h, borderRadius: 4.r),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 90.w, height: 10.h, borderRadius: 4.r),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16.r, color: AppTheme.borderLight),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 50.w, height: 10.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 70.w, height: 14.h, borderRadius: 4.r),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 90.w, height: 10.h, borderRadius: 4.r),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer list representing records being fetched on Admin Dashboard.
class AdminRecordsListShimmer extends StatelessWidget {
  final int itemCount;

  const AdminRecordsListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (index) => const AdminRecordCardShimmer(),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Attendance History summary card (3 metrics).
class HistorySummaryCardShimmer extends StatelessWidget {
  const HistorySummaryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMetricItemPlaceholder()),
          Container(
            height: 36.h,
            width: 1.w,
            color: AppTheme.borderLight,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Expanded(child: _buildMetricItemPlaceholder()),
          Container(
            height: 36.h,
            width: 1.w,
            color: AppTheme.borderLight,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Expanded(child: _buildMetricItemPlaceholder()),
        ],
      ),
    );
  }

  Widget _buildMetricItemPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 54.w, height: 11.h, borderRadius: 4.r),
        SizedBox(height: 6.h),
        ShimmerBox(width: 32.w, height: 18.h, borderRadius: 4.r),
      ],
    );
  }
}

/// Shimmer placeholder for a single attendance record card in History.
class HistoryRecordCardShimmer extends StatelessWidget {
  const HistoryRecordCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 110.w, height: 14.h, borderRadius: 4.r),
              ShimmerBox(width: 72.w, height: 22.h, borderRadius: 20.r),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: AppTheme.borderLight),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 50.w, height: 10.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 70.w, height: 14.h, borderRadius: 4.r),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 90.w, height: 10.h, borderRadius: 4.r),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16.r, color: AppTheme.borderLight),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 50.w, height: 10.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 70.w, height: 14.h, borderRadius: 4.r),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 90.w, height: 10.h, borderRadius: 4.r),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ShimmerBox(height: 32.h, borderRadius: 10.r),
        ],
      ),
    );
  }
}

/// Full shimmering skeleton for the Attendance History page while fetching.
class HistoryPageShimmer extends StatelessWidget {
  final int itemCount;

  const HistoryPageShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          const HistorySummaryCardShimmer(),
          SizedBox(height: 16.h),
          ShimmerBox(width: 160.w, height: 16.h, borderRadius: 4.r),
          SizedBox(height: 12.h),
          ...List.generate(itemCount, (index) => const HistoryRecordCardShimmer()),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for Employee Today Status card while fetching from API.
class TodayAttendanceCardShimmer extends StatelessWidget {
  const TodayAttendanceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 140.w, height: 15.h, borderRadius: 4.r),
                ShimmerBox(width: 90.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
            SizedBox(height: 16.h),
            ShimmerBox(height: 48.h, borderRadius: 12.r),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(height: 72.h, borderRadius: 12.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ShimmerBox(height: 72.h, borderRadius: 12.r),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ShimmerBox(height: 36.h, borderRadius: 10.r),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for QR Session Card while generating/fetching session.
class QrSessionGeneratingShimmer extends StatelessWidget {
  const QrSessionGeneratingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: EdgeInsets.all(28.r),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerBox(width: 120.w, height: 26.h, borderRadius: 20.r),
            SizedBox(height: 20.h),
            ShimmerBox(width: 200.r, height: 200.r, borderRadius: 16.r),
            SizedBox(height: 20.h),
            ShimmerBox(width: 140.w, height: 16.h, borderRadius: 6.r),
            SizedBox(height: 8.h),
            ShimmerBox(width: 180.w, height: 12.h, borderRadius: 4.r),
          ],
        ),
      ),
    );
  }
}
