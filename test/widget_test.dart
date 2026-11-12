import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/core/theme/app_theme.dart';
import 'package:markme/features/auth/domain/usecases/login_usecase.dart';
import 'package:markme/features/auth/domain/usecases/logout_usecase.dart';
import 'package:markme/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:markme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:markme/features/auth/presentation/pages/admin_login_page.dart';
import 'package:markme/features/auth/presentation/pages/employee_login_page.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRestoreSessionUseCase mockRestoreSessionUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late AuthBloc authBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRestoreSessionUseCase = MockRestoreSessionUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      restoreSessionUseCase: mockRestoreSessionUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  testWidgets('EmployeeLoginPage renders employee branding and form fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockRestoreSessionUseCase())
        .thenAnswer((_) async => const ErrorResult(UnauthorizedFailure()));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const EmployeeLoginPage(),
          ),
        ),
      ),
    );

    expect(find.text('MarkMe Employee'), findsOneWidget);
    expect(find.text('Employee Sign In'), findsOneWidget);
    expect(find.text('Work Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In to Employee Portal'), findsOneWidget);
    expect(find.text('Switch to Admin Portal'), findsOneWidget);
  });

  testWidgets('AdminLoginPage renders admin branding and form fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const AdminLoginPage(),
          ),
        ),
      ),
    );

    expect(find.text('MarkMe Admin'), findsOneWidget);
    expect(find.text('Administrator Sign In'), findsOneWidget);
    expect(find.text('Admin Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In to Admin Portal'), findsOneWidget);
    expect(find.text('Switch to Employee Portal'), findsOneWidget);
  });
}
