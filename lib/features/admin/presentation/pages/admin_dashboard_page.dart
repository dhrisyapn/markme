import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/admin_attendance_record.dart';
import '../bloc/admin_records/admin_records_bloc.dart';
import '../bloc/admin_records/admin_records_event.dart';
import '../bloc/admin_records/admin_records_state.dart';
import '../widgets/qr_duration_picker_sheet.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AdminRecordsBloc>().add(const AdminRecordsFetchRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminRecordsBloc>().add(
        const AdminRecordsNextPageRequested(),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of the Admin console?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.statusError,
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormatter.formatWorkDate(picked);
      if (mounted) {
        context.read<AdminRecordsBloc>().add(
          AdminRecordsDateFilterChanged(formatted),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryBlue,
          onRefresh: () async {
            context.read<AdminRecordsBloc>().add(const AdminRecordsRefreshed());
          },
          child: BlocBuilder<AdminRecordsBloc, AdminRecordsState>(
            builder: (context, state) {
              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildQrActionHeroCard(),
                          SizedBox(height: 16.h),
                          if (state is AdminRecordsLoaded)
                            _buildMetricsRow(state),
                          SizedBox(height: 20.h),
                          _buildFilterAndSearchSection(state),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Employee Attendance Records',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (state is AdminRecordsLoaded)
                                Text(
                                  '${state.records.length} shown',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ),

                  // Records Content List
                  if (state is AdminRecordsLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    )
                  else if (state is AdminRecordsError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48.r,
                                color: AppTheme.statusError,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              FilledButton(
                                onPressed: () {
                                  context.read<AdminRecordsBloc>().add(
                                    const AdminRecordsFetchRequested(),
                                  );
                                },
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (state is AdminRecordsLoaded)
                    if (state.records.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == state.records.length) {
                                return state.isFetchingNextPage
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24.h,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 24.r,
                                            height: 24.r,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(height: 40.h);
                              }
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _buildRecordCard(state.records[index]),
                              );
                            },
                            childCount:
                                state.records.length + (state.hasMore ? 1 : 0),
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 20.w,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String name = 'Admin';
          String code = 'ADM001';
          if (state is Authenticated) {
            name = state.profile.name;
            code = state.profile.employeeCode;
          }

          return Row(
            children: [
              CircleAvatar(
                radius: 19.r,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySurface,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          code,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Admin Portal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Sign Out',
          icon: Icon(
            Icons.logout_rounded,
            size: 22.r,
            color: AppTheme.textSecondary,
          ),
          onPressed: _showLogoutDialog,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildQrActionHeroCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () async {
            final duration = await showQrDurationPickerSheet(context);
            if (duration != null && mounted) {
              context.push('/admin/qr-session', extra: duration);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.white,
                    size: 30.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate QR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Start a time-limited check-in session for employees',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 14.r,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(AdminRecordsLoaded state) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildMetricCard(
              label: "Today's Check-Ins",
              value: state.todayCheckIns.toString(),
              icon: Icons.login_rounded,
              color: AppTheme.primaryLight,
              bgColor: AppTheme.primarySurface,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildMetricCard(
              label: "Completed Today",
              value: state.todayCompleted.toString(),
              icon: Icons.task_alt_rounded,
              color: AppTheme.statusSuccess,
              bgColor: AppTheme.statusSuccessSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    height: 1.25,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchSection(AdminRecordsState state) {
    String? selectedDate;
    if (state is AdminRecordsLoaded) {
      selectedDate = state.selectedDate;
    }
    final today = DateFormatter.todayUtcString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by employee name or code...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textMuted,
              size: 20.r,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, size: 18.r),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AdminRecordsBloc>().add(
                        const AdminRecordsSearchChanged(''),
                      );
                    },
                  )
                : null,
            fillColor: AppTheme.surfaceWhite,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          onChanged: (val) {
            context.read<AdminRecordsBloc>().add(
              AdminRecordsSearchChanged(val),
            );
          },
        ),
        SizedBox(height: 12.h),

        // Date Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: selectedDate == null,
                label: const Text('All Dates'),
                selectedColor: AppTheme.primaryBlue,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selectedDate == null
                      ? Colors.white
                      : AppTheme.textSecondary,
                ),
                backgroundColor: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                side: BorderSide(
                  color: selectedDate == null
                      ? AppTheme.primaryBlue
                      : AppTheme.borderLight,
                ),
                onSelected: (_) {
                  context.read<AdminRecordsBloc>().add(
                    const AdminRecordsDateFilterChanged(null),
                  );
                },
              ),
              SizedBox(width: 8.w),
              FilterChip(
                selected: selectedDate == today,
                label: const Text('Today'),
                selectedColor: AppTheme.primaryBlue,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selectedDate == today
                      ? Colors.white
                      : AppTheme.textSecondary,
                ),
                backgroundColor: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                side: BorderSide(
                  color: selectedDate == today
                      ? AppTheme.primaryBlue
                      : AppTheme.borderLight,
                ),
                onSelected: (_) {
                  context.read<AdminRecordsBloc>().add(
                    AdminRecordsDateFilterChanged(today),
                  );
                },
              ),
              SizedBox(width: 8.w),
              ActionChip(
                avatar: Icon(
                  Icons.calendar_today_rounded,
                  size: 14.r,
                  color: (selectedDate != null && selectedDate != today)
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                ),
                label: Text(
                  (selectedDate != null && selectedDate != today)
                      ? selectedDate
                      : 'Pick Date',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: (selectedDate != null && selectedDate != today)
                        ? AppTheme.primaryBlue
                        : AppTheme.textSecondary,
                  ),
                ),
                backgroundColor: (selectedDate != null && selectedDate != today)
                    ? AppTheme.primarySurface
                    : AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                side: BorderSide(
                  color: (selectedDate != null && selectedDate != today)
                      ? AppTheme.primaryBlue
                      : AppTheme.borderLight,
                ),
                onPressed: _pickCustomDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(AdminAttendanceRecord record) {
    final isCompleted = record.isCompleted;

    return Container(
      padding: EdgeInsets.all(16.0.r),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Employee Avatar, Name, Code, and Status Badge
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppTheme.primarySurface,
                child: Text(
                  record.employeeName.isNotEmpty
                      ? record.employeeName[0].toUpperCase()
                      : 'E',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.employeeName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            record.employeeCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          DateFormatter.formatDisplayDate(record.workDate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.statusSuccessSurface
                      : AppTheme.statusWarningSurface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(),
          SizedBox(height: 12.h),

          // Check-in & Check-out details
          Row(
            children: [
              // Check In Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: 14.r,
                          color: AppTheme.primaryLight,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'CHECK IN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
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
                    if (record.checkInLat != null &&
                        record.checkInLng != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.r,
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${record.checkInLat!.toStringAsFixed(3)}, ${record.checkInLng!.toStringAsFixed(3)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Divider arrow
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.r,
                  color: AppTheme.borderLight,
                ),
              ),

              // Check Out Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 14.r,
                          color: isCompleted
                              ? AppTheme.statusSuccess
                              : AppTheme.textMuted,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'CHECK OUT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      record.checkOutAt != null
                          ? DateFormatter.formatTime(record.checkOutAt)
                          : 'Pending',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: record.checkOutAt != null
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                      ),
                    ),
                    if (record.checkOutLat != null &&
                        record.checkOutLng != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.r,
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${record.checkOutLat!.toStringAsFixed(3)}, ${record.checkOutLng!.toStringAsFixed(3)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: AppTheme.textMuted,
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

          // Total Duration Pill if completed
          if (isCompleted) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14.r,
                    color: AppTheme.primaryBlue,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Work Duration: ${DateFormatter.formatDuration(record.checkInAt, record.checkOutAt)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: const BoxDecoration(
                color: AppTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 32.r,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Attendance Records',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'No employees have marked attendance matching the current filters.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
