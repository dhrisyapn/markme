import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/qr_session/qr_session_bloc.dart';
import '../bloc/qr_session/qr_session_event.dart';
import '../bloc/qr_session/qr_session_state.dart';
import '../widgets/qr_duration_picker_sheet.dart';

class QrSessionPage extends StatefulWidget {
  final int? initialDurationMinutes;

  const QrSessionPage({super.key, this.initialDurationMinutes});

  @override
  State<QrSessionPage> createState() => _QrSessionPageState();
}

class _QrSessionPageState extends State<QrSessionPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<QrSessionBloc>();
    if (widget.initialDurationMinutes != null) {
      bloc.add(
        QrGenerateRequested(durationMinutes: widget.initialDurationMinutes),
      );
    } else if (bloc.state is QrInitial || bloc.state is QrExpired) {
      bloc.add(const QrGenerateRequested());
    }
  }

  Future<void> _openDurationPicker() async {
    final bloc = context.read<QrSessionBloc>();
    final currentMinutes = bloc.state is QrActive
        ? ((bloc.state as QrActive).totalSeconds / 60).round()
        : 2;

    final duration = await showQrDurationPickerSheet(
      context,
      initialDurationMinutes: currentMinutes > 0 ? currentMinutes : 2,
    );

    if (duration != null && mounted) {
      bloc.add(QrGenerateRequested(durationMinutes: duration));
    }
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDurationLimit(int totalSeconds) {
    final minutes = (totalSeconds / 60).round();
    if (minutes <= 1) {
      if (totalSeconds < 60) return '$totalSeconds-SEC LIMIT';
      return '1-MIN LIMIT';
    }
    return '$minutes-MIN LIMIT';
  }

  Color _getTimerColor(int secondsLeft) {
    if (secondsLeft > 60) return AppTheme.primaryLight;
    if (secondsLeft > 20) return AppTheme.statusWarning;
    return AppTheme.statusError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Live Attendance QR',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480.w),
              child: BlocBuilder<QrSessionBloc, QrSessionState>(
                builder: (context, state) {
                  if (state is QrGenerating) {
                    return _buildGeneratingCard();
                  }

                  if (state is QrActive) {
                    return _buildActiveQrCard(state);
                  }

                  if (state is QrExpired) {
                    return _buildExpiredCard(state);
                  }

                  if (state is QrError) {
                    return _buildErrorCard(state.message);
                  }

                  return _buildInitialCard();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveQrCard(QrActive state) {
    final timerColor = _getTimerColor(state.secondsLeft);
    final durationLimitText = _formatDurationLimit(state.totalSeconds);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Security Status Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.statusSuccessSurface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: AppTheme.statusSuccess,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'SESSION ACTIVE ($durationLimitText)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF065F46),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // QR Presentation Card
        Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code View
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: state.session.payloadJson,
                  version: QrVersions.auto,
                  size: 240.0.r,
                  gapless: true,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppTheme.primaryDark,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Countdown Timer Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: timerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: timerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 20.r,
                              color: timerColor,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Time Remaining',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: timerColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatSeconds(state.secondsLeft),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: timerColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: state.progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                        minHeight: 6.h,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Session Metadata
              Text(
                'Session ID: ${state.session.sessionId.substring(0, 8)}...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Custom Duration Button below QR
        OutlinedButton.icon(
          onPressed: _openDurationPicker,
          icon: Icon(Icons.tune_rounded, size: 18.r),
          label: Text(
            'Change Expiration / New QR',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppTheme.surfaceWhite,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Info Instructions Card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primaryBlue,
                size: 22.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions for Employees',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Employees must open the MarkMe app and scan this QR code to mark check-in or check-out with GPS coordinates.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiredCard(QrExpired state) {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: const BoxDecoration(
              color: AppTheme.statusErrorSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_off_outlined,
              size: 38.r,
              color: AppTheme.statusError,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'QR Session Expired',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The attendance window for this session has ended to prevent unauthorized scans.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          FilledButton.icon(
            onPressed: _openDurationPicker,
            icon: Icon(Icons.timer_outlined, size: 20.r),
            label: Text(
              'Generate new QR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingCard() {
    return Container(
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44.r,
            height: 44.r,
            child: const CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Creating Secure QR Session...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Contacting server to register session token',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.r,
            color: AppTheme.statusError,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to Generate Session',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: () {
              context.read<QrSessionBloc>().add(const QrGenerateRequested());
            },
            icon: Icon(Icons.refresh_rounded, size: 18.r),
            label: Text(
              'Try Again',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton.icon(
            onPressed: _openDurationPicker,
            icon: Icon(Icons.tune_rounded, size: 18.r),
            label: Text(
              'Choose Different Duration',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialCard() {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 36.r,
              color: AppTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Generate QR',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Set custom expiration time and generate a live QR code for employees.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: _openDurationPicker,
            icon: Icon(Icons.timer_outlined, size: 20.r),
            label: Text(
              'Select Duration & Generate QR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
