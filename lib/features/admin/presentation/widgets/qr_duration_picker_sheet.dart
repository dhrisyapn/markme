import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// Shows a modal bottom sheet prompting the admin to choose an expiration duration
/// in minutes before generating the attendance QR code.
Future<int?> showQrDurationPickerSheet(
  BuildContext context, {
  int initialDurationMinutes = 2,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => QrDurationPickerSheet(
      initialDurationMinutes: initialDurationMinutes,
    ),
  );
}

class QrDurationPickerSheet extends StatefulWidget {
  final int initialDurationMinutes;

  const QrDurationPickerSheet({
    super.key,
    this.initialDurationMinutes = 2,
  });

  @override
  State<QrDurationPickerSheet> createState() => _QrDurationPickerSheetState();
}

class _QrDurationPickerSheetState extends State<QrDurationPickerSheet> {
  static const List<int> _presetDurations = [1, 2, 5, 10, 15, 30, 60];
  late int _selectedMinutes;
  late final TextEditingController _customController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialDurationMinutes.clamp(1, 120);
    _customController = TextEditingController(text: _selectedMinutes.toString());
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _onPresetSelected(int minutes) {
    setState(() {
      _selectedMinutes = minutes;
      _customController.text = minutes.toString();
    });
  }

  void _incrementMinutes() {
    if (_selectedMinutes < 120) {
      setState(() {
        _selectedMinutes++;
        _customController.text = _selectedMinutes.toString();
      });
    }
  }

  void _decrementMinutes() {
    if (_selectedMinutes > 1) {
      setState(() {
        _selectedMinutes--;
        _customController.text = _selectedMinutes.toString();
      });
    }
  }

  void _onCustomSubmitted(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1 && parsed <= 120) {
      setState(() {
        _selectedMinutes = parsed;
      });
    }
  }

  void _confirmSelection() {
    final parsed = int.tryParse(_customController.text.trim());
    final finalMinutes = (parsed != null && parsed >= 1 && parsed <= 120)
        ? parsed
        : _selectedMinutes;

    Navigator.of(context).pop(finalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom Sheet Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title and Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: AppTheme.primaryBlue,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set QR Expiration',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Select duration in minutes for QR validity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, size: 20.r, color: AppTheme.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Quick Presets Label
              Text(
                'QUICK PRESETS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 10.h),

              // Preset Buttons Wrap
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _presetDurations.map((minutes) {
                  final isSelected = _selectedMinutes == minutes;
                  final isDefault = minutes == 2;

                  return ChoiceChip(
                    label: Text(
                      isDefault ? '$minutes min (Default)' : '$minutes min',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _onPresetSelected(minutes),
                    selectedColor: AppTheme.primarySurface,
                    backgroundColor: AppTheme.backgroundLight,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),

              // Custom Duration Input Label
              Text(
                'CUSTOM DURATION (MINUTES)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 10.h),

              // Stepper & Text Field Row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    // Decrement Button
                    IconButton(
                      icon: Icon(Icons.remove_rounded, size: 22.r),
                      color: _selectedMinutes > 1 ? AppTheme.primaryBlue : AppTheme.textMuted,
                      onPressed: _selectedMinutes > 1 ? _decrementMinutes : null,
                    ),
                    SizedBox(width: 8.w),

                    // Number input
                    Expanded(
                      child: TextFormField(
                        controller: _customController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                          suffixText: 'min',
                          suffixStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        onChanged: _onCustomSubmitted,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Increment Button
                    IconButton(
                      icon: Icon(Icons.add_rounded, size: 22.r),
                      color: _selectedMinutes < 120 ? AppTheme.primaryBlue : AppTheme.textMuted,
                      onPressed: _selectedMinutes < 120 ? _incrementMinutes : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Minimum 1 minute, maximum 120 minutes (2 hours).',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: AppTheme.textMuted,
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              FilledButton.icon(
                onPressed: _confirmSelection,
                icon: Icon(Icons.qr_code_rounded, size: 20.r),
                label: Text(
                  'Generate QR Code ($_selectedMinutes ${_selectedMinutes == 1 ? 'min' : 'mins'})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

