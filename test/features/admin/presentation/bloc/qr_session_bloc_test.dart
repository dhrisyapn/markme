import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/features/admin/domain/entities/qr_session.dart';
import 'package:markme/features/admin/domain/usecases/create_qr_session_usecase.dart';
import 'package:markme/features/admin/presentation/bloc/qr_session/qr_session_bloc.dart';
import 'package:markme/features/admin/presentation/bloc/qr_session/qr_session_event.dart';
import 'package:markme/features/admin/presentation/bloc/qr_session/qr_session_state.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateQrSessionUseCase extends Mock implements CreateQrSessionUseCase {}

void main() {
  late MockCreateQrSessionUseCase mockCreateQrSessionUseCase;
  late QrSessionBloc qrSessionBloc;

  final testSession = QrSession(
    sessionId: 'session-1234',
    token: 'token-abcd',
    expiresInSeconds: 120,
    expiresAt: DateTime.now().add(const Duration(seconds: 120)),
  );

  final testCustomSession = QrSession(
    sessionId: 'session-5678',
    token: 'token-custom',
    expiresInSeconds: 300,
    expiresAt: DateTime.now().add(const Duration(seconds: 300)),
  );

  setUp(() {
    mockCreateQrSessionUseCase = MockCreateQrSessionUseCase();
    qrSessionBloc = QrSessionBloc(
      createQrSessionUseCase: mockCreateQrSessionUseCase,
    );
  });

  tearDown(() {
    qrSessionBloc.close();
  });

  group('QrSessionBloc', () {
    test('initial state is QrInitial', () {
      expect(qrSessionBloc.state, const QrInitial());
    });

    blocTest<QrSessionBloc, QrSessionState>(
      'emits [QrGenerating, QrActive] when QrGenerateRequested succeeds with default duration',
      build: () {
        when(() => mockCreateQrSessionUseCase(durationMinutes: any(named: 'durationMinutes')))
            .thenAnswer((_) async => Success(testSession));
        return qrSessionBloc;
      },
      act: (bloc) => bloc.add(const QrGenerateRequested()),
      expect: () => [
        const QrGenerating(),
        QrActive(
          session: testSession,
          secondsLeft: 120,
          totalSeconds: 120,
        ),
      ],
      verify: (_) {
        verify(() => mockCreateQrSessionUseCase(durationMinutes: 2)).called(1);
      },
    );

    blocTest<QrSessionBloc, QrSessionState>(
      'emits [QrGenerating, QrActive] when QrGenerateRequested succeeds with custom duration (5 min)',
      build: () {
        when(() => mockCreateQrSessionUseCase(durationMinutes: 5))
            .thenAnswer((_) async => Success(testCustomSession));
        return qrSessionBloc;
      },
      act: (bloc) => bloc.add(const QrGenerateRequested(durationMinutes: 5)),
      expect: () => [
        const QrGenerating(),
        QrActive(
          session: testCustomSession,
          secondsLeft: 300,
          totalSeconds: 300,
        ),
      ],
      verify: (_) {
        verify(() => mockCreateQrSessionUseCase(durationMinutes: 5)).called(1);
      },
    );

    blocTest<QrSessionBloc, QrSessionState>(
      'emits [QrGenerating, QrError] when QrGenerateRequested fails',
      build: () {
        when(() => mockCreateQrSessionUseCase(durationMinutes: any(named: 'durationMinutes')))
            .thenAnswer((_) async => const ErrorResult(ForbiddenFailure()));
        return qrSessionBloc;
      },
      act: (bloc) => bloc.add(const QrGenerateRequested()),
      expect: () => [
        const QrGenerating(),
        const QrError('You do not have permission to perform this action.'),
      ],
    );

    blocTest<QrSessionBloc, QrSessionState>(
      'emits QrExpired when QrTicked reaches 0 seconds',
      build: () {
        when(() => mockCreateQrSessionUseCase(durationMinutes: any(named: 'durationMinutes')))
            .thenAnswer((_) async => Success(testSession));
        return qrSessionBloc;
      },
      seed: () => QrActive(
        session: testSession,
        secondsLeft: 1,
        totalSeconds: 120,
      ),
      act: (bloc) => bloc.add(const QrTicked(0)),
      expect: () => [
        const QrExpired(null),
      ],
    );
  });
}
