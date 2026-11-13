import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/location_service.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../widgets/scan_result_dialog.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _controller;
  late final AnimationController _scanAnimationController;
  late final Animation<double> _scanAnimation;

  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      _restartCamera();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  Future<void> _restartCamera() async {
    try {
      await _controller.start();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Ignored if already started or currently transitioning
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawCode = barcodes.first.rawValue;
    if (rawCode == null || rawCode.trim().isEmpty) return;

    _processQrCode(rawCode);
  }

  Future<void> _processQrCode(String code) async {
    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    try {
      // 1. Fetch GPS coordinates
      final locationService = sl<LocationService>();
      final position = await locationService.getCurrentLocation();

      if (!mounted) return;

      // 2. Dispatch QR scan event to AttendanceBloc
      context.read<AttendanceBloc>().add(
            QrScanned(
              rawQrCode: code,
              lat: position.latitude,
              lng: position.longitude,
            ),
          );
    } on LocationException catch (e) {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        failure: LocationFailure(e.message),
      );
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        failure: ServerFailure('Location error: ${e.toString()}'),
      );
    }
  }

  void _showResultDialog({
    required bool isSuccess,
    dynamic action,
    dynamic record,
    Failure? failure,
  }) {
    ScanResultDialog.show(
      context: context,
      isSuccess: isSuccess,
      action: action,
      record: record,
      failure: failure,
      onDismiss: () {
        if (isSuccess) {
          context.pop(true);
        } else {
          _resumeScanning();
        }
      },
      onRetry: !isSuccess && _lastScannedCode != null
          ? () => _processQrCode(_lastScannedCode!)
          : null,
    );
  }

  void _resumeScanning() {
    setState(() {
      _isProcessing = false;
      _lastScannedCode = null;
    });
    context.read<AttendanceBloc>().add(const AttendanceReset());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          _showResultDialog(
            isSuccess: true,
            action: state.action,
            record: state.record,
          );
        } else if (state is AttendanceFailure) {
          _showResultDialog(
            isSuccess: false,
            failure: state.failure,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Live Mobile Scanner
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return _buildScannerErrorView(error);
              },
            ),

            // Semi-transparent overlay with cutout and scanning laser (only when active without error)
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (state.error != null) {
                  return const SizedBox.shrink();
                }
                return Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _ScannerOverlayPainter(
                        boxSize: 260.r,
                        borderRadius: 20.r,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 260.r,
                        height: 260.r,
                        child: AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                              child: Container(
                                height: 3.h,
                                width: 240.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryLight.withValues(alpha: 0.1),
                                      AppTheme.primaryLight,
                                      AppTheme.primaryLight.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryLight.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top Bar Controls
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    _buildCircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.pop(),
                    ),
                    // GPS status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gps_fixed_rounded, color: AppTheme.statusSuccess, size: 14.r),
                          SizedBox(width: 6.w),
                          Text(
                            'GPS High Accuracy',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Torch / Flashlight Toggle
                    ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _controller,
                      builder: (context, state, child) {
                        final isTorchOn = state.torchState == TorchState.on;
                        return _buildCircleIconButton(
                          icon: isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: isTorchOn ? Colors.amber : Colors.white,
                          onPressed: () => _controller.toggleTorch(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Instructions and Loading Banner (only when camera is operational without error)
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (state.error != null) {
                  return const SizedBox.shrink();
                }
                return SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36.h, left: 24.w, right: 24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isProcessing) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceWhite,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Flexible(
                                    child: Text(
                                      'Verifying GPS & QR session...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Align the MarkMe QR Code within the frame',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Make sure you are at the authorized workplace location',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerErrorView(MobileScannerException error) {
    final bool isPermissionError =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isPermissionError ? AppTheme.statusWarning : AppTheme.statusError,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: isPermissionError
                      ? AppTheme.statusWarningSurface
                      : AppTheme.statusErrorSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPermissionError
                      ? Icons.no_photography_rounded
                      : Icons.error_outline_rounded,
                  color: isPermissionError
                      ? AppTheme.statusWarning
                      : AppTheme.statusError,
                  size: 28.r,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                isPermissionError
                    ? 'Camera Permission Required'
                    : 'Camera Initialization Failed',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isPermissionError
                    ? 'MarkMe needs access to your camera to scan attendance QR codes. Please grant camera permission to continue.'
                    : 'Unable to start camera preview. Tap the button below to retry.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              FilledButton.icon(
                onPressed: _restartCamera,
                icon: Icon(Icons.refresh_rounded, size: 18.r),
                label: Text(
                  isPermissionError ? 'Grant Permission / Retry' : 'Retry Camera',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              if (isPermissionError) ...[
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: Text(
                    'Open App Settings',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primaryLight,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22.r),
        onPressed: onPressed,
      ),
    );
  }
}

/// Custom painter for semi-transparent overlay with a clear rounded rectangular cutout.
class _ScannerOverlayPainter extends CustomPainter {
  final double boxSize;
  final double borderRadius;

  const _ScannerOverlayPainter({
    required this.boxSize,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: boxSize,
      height: boxSize,
    );

    // Create transparent cutout path
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // Draw Royal Blue corners
    final cornerPaint = Paint()
      ..color = AppTheme.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final cornerLength = 28.0.r;

    // Top-Left
    canvas.drawLine(Offset(rect.left, rect.top + cornerLength), Offset(rect.left, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLength, rect.top), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(rect.right - cornerLength, rect.top), Offset(rect.right, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLength), Offset(rect.left, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLength, rect.bottom), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(rect.right - cornerLength, rect.bottom), Offset(rect.right, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
