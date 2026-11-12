import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/core/routes/app_router.dart';
import 'package:markme/features/auth/domain/usecases/login_usecase.dart';
import 'package:markme/features/auth/domain/usecases/logout_usecase.dart';
import 'package:markme/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:markme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  testWidgets('Switch to Admin Portal and back to Employee Portal works seamlessly', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockLogin = MockLoginUseCase();
    final mockRestore = MockRestoreSessionUseCase();
    final mockLogout = MockLogoutUseCase();
    when(() => mockRestore()).thenAnswer((_) async => const ErrorResult(UnauthorizedFailure()));

    final authBloc = AuthBloc(
      loginUseCase: mockLogin,
      restoreSessionUseCase: mockRestore,
      logoutUseCase: mockLogout,
    );

    final router = createRouter(authBloc);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Starts on Employee Portal
    expect(find.text('Employee Sign In'), findsOneWidget);
    expect(find.text('Switch to Admin Portal'), findsOneWidget);

    // Tap Switch to Admin Portal
    await tester.tap(find.text('Switch to Admin Portal'));
    await tester.pumpAndSettle();

    // Now on Admin Portal
    expect(find.text('Administrator Sign In'), findsOneWidget);
    expect(find.text('Switch to Employee Portal'), findsOneWidget);

    // Tap Switch to Employee Portal
    await tester.tap(find.text('Switch to Employee Portal'));
    await tester.pumpAndSettle();

    // Back to Employee Portal
    expect(find.text('Employee Sign In'), findsOneWidget);
  });
}
