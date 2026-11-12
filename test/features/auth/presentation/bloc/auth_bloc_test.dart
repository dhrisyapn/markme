import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/features/auth/domain/entities/employee_profile.dart';
import 'package:markme/features/auth/domain/entities/user_role.dart';
import 'package:markme/features/auth/domain/usecases/login_usecase.dart';
import 'package:markme/features/auth/domain/usecases/logout_usecase.dart';
import 'package:markme/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:markme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:markme/features/auth/presentation/bloc/auth_event.dart';
import 'package:markme/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRestoreSessionUseCase mockRestoreSessionUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late AuthBloc authBloc;

  const testAdmin = EmployeeProfile(
    id: 'admin-uuid',
    employeeCode: 'ADM001',
    name: 'System Admin',
    email: 'admin@markme.com',
    role: UserRole.admin,
  );

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

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when AppStarted successfully restores session',
      build: () {
        when(() => mockRestoreSessionUseCase())
            .thenAnswer((_) async => const Success(testAdmin));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(message: 'Checking session...'),
        const Authenticated(testAdmin),
      ],
      verify: (_) {
        verify(() => mockRestoreSessionUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when AppStarted fails to restore session',
      build: () {
        when(() => mockRestoreSessionUseCase())
            .thenAnswer((_) async => const ErrorResult(UnauthorizedFailure('No session')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(message: 'Checking session...'),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful LoginSubmitted',
      build: () {
        when(() => mockLoginUseCase(
              email: 'admin@markme.com',
              password: 'Password123!',
            )).thenAnswer((_) async => const Success(testAdmin));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(
        email: 'admin@markme.com',
        password: 'Password123!',
      )),
      expect: () => [
        const AuthLoading(message: 'Signing in...'),
        const Authenticated(testAdmin),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginSubmitted fails',
      build: () {
        when(() => mockLoginUseCase(
              email: 'admin@markme.com',
              password: 'wrong-password',
            )).thenAnswer((_) async => const ErrorResult(UnauthorizedFailure('Invalid credentials.')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(
        email: 'admin@markme.com',
        password: 'wrong-password',
      )),
      expect: () => [
        const AuthLoading(message: 'Signing in...'),
        const AuthError('Invalid credentials.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when LogoutRequested is dispatched',
      build: () {
        when(() => mockLogoutUseCase())
            .thenAnswer((_) async => const Success(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(message: 'Signing out...'),
        const Unauthenticated(),
      ],
      verify: (_) {
        verify(() => mockLogoutUseCase()).called(1);
      },
    );
  });
}

