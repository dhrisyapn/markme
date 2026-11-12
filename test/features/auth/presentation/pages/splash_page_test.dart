import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/core/routes/app_router.dart';
import 'package:markme/core/theme/app_theme.dart';
import 'package:markme/features/admin/presentation/bloc/admin_records/admin_records_bloc.dart';
import 'package:markme/features/admin/presentation/bloc/admin_records/admin_records_state.dart';
import 'package:markme/features/admin/presentation/bloc/qr_session/qr_session_bloc.dart';
import 'package:markme/features/admin/presentation/bloc/qr_session/qr_session_state.dart';
import 'package:markme/features/attendance/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:markme/features/attendance/presentation/bloc/attendance/attendance_state.dart';
import 'package:markme/features/attendance/presentation/bloc/history/history_bloc.dart';
import 'package:markme/features/attendance/presentation/bloc/history/history_state.dart';
import 'package:markme/features/auth/domain/entities/employee_profile.dart';
import 'package:markme/features/auth/domain/entities/user_role.dart';
import 'package:markme/features/auth/domain/usecases/login_usecase.dart';
import 'package:markme/features/auth/domain/usecases/logout_usecase.dart';
import 'package:markme/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:markme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:markme/features/auth/presentation/pages/splash_page.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockQrSessionBloc extends Mock implements QrSessionBloc {}
class MockAdminRecordsBloc extends Mock implements AdminRecordsBloc {}
class MockAttendanceBloc extends Mock implements AttendanceBloc {}
class MockHistoryBloc extends Mock implements HistoryBloc {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRestoreSessionUseCase mockRestoreSessionUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockAttendanceBloc mockAttendanceBloc;
  late MockAdminRecordsBloc mockAdminRecordsBloc;
  late MockQrSessionBloc mockQrSessionBloc;
  late MockHistoryBloc mockHistoryBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRestoreSessionUseCase = MockRestoreSessionUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAttendanceBloc = MockAttendanceBloc();
    mockAdminRecordsBloc = MockAdminRecordsBloc();
    mockQrSessionBloc = MockQrSessionBloc();
    mockHistoryBloc = MockHistoryBloc();

    when(() => mockAttendanceBloc.state).thenReturn(const AttendanceInitial());
    when(() => mockAttendanceBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockAdminRecordsBloc.state).thenReturn(const AdminRecordsInitial());
    when(() => mockAdminRecordsBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockQrSessionBloc.state).thenReturn(const QrInitial());
    when(() => mockQrSessionBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockHistoryBloc.state).thenReturn(const HistoryInitial());
    when(() => mockHistoryBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestApp({required AuthBloc authBloc, GoRouter? router}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AttendanceBloc>.value(value: mockAttendanceBloc),
        BlocProvider<AdminRecordsBloc>.value(value: mockAdminRecordsBloc),
        BlocProvider<QrSessionBloc>.value(value: mockQrSessionBloc),
        BlocProvider<HistoryBloc>.value(value: mockHistoryBloc),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => router != null
            ? MaterialApp.router(
                theme: AppTheme.lightTheme,
                routerConfig: router,
              )
            : MaterialApp(
                theme: AppTheme.lightTheme,
                home: const SplashPage(),
              ),
      ),
    );
  }

  testWidgets('SplashPage renders centered MarkMe title and QR icon', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockRestoreSessionUseCase())
        .thenAnswer((_) async => const ErrorResult(UnauthorizedFailure()));

    final authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      restoreSessionUseCase: mockRestoreSessionUseCase,
      logoutUseCase: mockLogoutUseCase,
    );

    await tester.pumpWidget(buildTestApp(authBloc: authBloc));
    await tester.pump();

    expect(find.text('MarkMe'), findsOneWidget);
    expect(find.text('Smart QR Attendance'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    authBloc.close();
  });

  testWidgets('SplashPage navigates to /login/employee when session is unauthenticated', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockRestoreSessionUseCase())
        .thenAnswer((_) async => const ErrorResult(UnauthorizedFailure()));

    final authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      restoreSessionUseCase: mockRestoreSessionUseCase,
      logoutUseCase: mockLogoutUseCase,
    );

    final router = createRouter(authBloc);

    await tester.pumpWidget(buildTestApp(authBloc: authBloc, router: router));
    await tester.pumpAndSettle();

    expect(find.text('Employee Sign In'), findsOneWidget);
    expect(find.text('Switch to Admin Portal'), findsOneWidget);

    authBloc.close();
  });

  testWidgets('SplashPage navigates to /employee/home when session is authenticated as employee', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const employeeProfile = EmployeeProfile(
      id: 'emp-123',
      employeeCode: 'EMP006',
      name: 'User One',
      email: 'user1@mail.com',
      role: UserRole.employee,
    );

    when(() => mockRestoreSessionUseCase())
        .thenAnswer((_) async => const Success(employeeProfile));

    final authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      restoreSessionUseCase: mockRestoreSessionUseCase,
      logoutUseCase: mockLogoutUseCase,
    );

    final router = createRouter(authBloc);

    await tester.pumpWidget(buildTestApp(authBloc: authBloc, router: router));
    await tester.pumpAndSettle();

    expect(find.text('User One'), findsOneWidget);
    expect(find.text('EMP006'), findsOneWidget);

    authBloc.close();
  });

  testWidgets('SplashPage navigates to /admin/dashboard when session is authenticated as admin', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const adminProfile = EmployeeProfile(
      id: 'adm-001',
      employeeCode: 'ADM001',
      name: 'Admin User',
      email: 'admin@markme.com',
      role: UserRole.admin,
    );

    when(() => mockRestoreSessionUseCase())
        .thenAnswer((_) async => const Success(adminProfile));

    final authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      restoreSessionUseCase: mockRestoreSessionUseCase,
      logoutUseCase: mockLogoutUseCase,
    );

    final router = createRouter(authBloc);

    await tester.pumpWidget(buildTestApp(authBloc: authBloc, router: router));
    await tester.pumpAndSettle();

    expect(find.text('Admin Portal'), findsOneWidget);

    authBloc.close();
  });
}
