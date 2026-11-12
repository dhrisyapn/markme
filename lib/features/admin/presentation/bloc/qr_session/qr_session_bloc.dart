import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/qr_session.dart';
import '../../../domain/usecases/create_qr_session_usecase.dart';
import 'qr_session_event.dart';
import 'qr_session_state.dart';

class QrSessionBloc extends Bloc<QrSessionEvent, QrSessionState> {
  final CreateQrSessionUseCase createQrSessionUseCase;
  StreamSubscription<int>? _tickerSubscription;
  QrSession? _currentSession;
  int _totalDurationSeconds = 120;
  int _lastDurationMinutes = 2;

  QrSessionBloc({
    required this.createQrSessionUseCase,
  }) : super(const QrInitial()) {
    on<QrGenerateRequested>(_onGenerateRequested);
    on<QrTicked>(_onTicked);
    on<QrResetRequested>(_onResetRequested);
  }

  Future<void> _onGenerateRequested(
    QrGenerateRequested event,
    Emitter<QrSessionState> emit,
  ) async {
    await _tickerSubscription?.cancel();
    emit(const QrGenerating());

    final requestedDuration = event.durationMinutes ?? _lastDurationMinutes;
    _lastDurationMinutes = requestedDuration;

    final result = await createQrSessionUseCase(durationMinutes: requestedDuration);

    if (result.isSuccess) {
      final session = result.data;
      _currentSession = session;
      _totalDurationSeconds = session.expiresInSeconds;

      emit(QrActive(
        session: session,
        secondsLeft: session.expiresInSeconds,
        totalSeconds: _totalDurationSeconds,
      ));

      _startTicker(session.expiresInSeconds);
    } else {
      emit(QrError(result.failure.message));
    }
  }

  void _onTicked(
    QrTicked event,
    Emitter<QrSessionState> emit,
  ) {
    if (event.secondsLeft <= 0) {
      _tickerSubscription?.cancel();
      emit(QrExpired(_currentSession));
    } else if (_currentSession != null) {
      emit(QrActive(
        session: _currentSession!,
        secondsLeft: event.secondsLeft,
        totalSeconds: _totalDurationSeconds,
      ));
    }
  }

  Future<void> _onResetRequested(
    QrResetRequested event,
    Emitter<QrSessionState> emit,
  ) async {
    await _tickerSubscription?.cancel();
    _currentSession = null;
    emit(const QrInitial());
  }

  void _startTicker(int durationSeconds) {
    _tickerSubscription?.cancel();
    _tickerSubscription = Stream.periodic(
      const Duration(seconds: 1),
      (computationCount) => durationSeconds - computationCount - 1,
    ).listen((remaining) {
      add(QrTicked(remaining));
    });
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
