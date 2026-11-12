import 'package:equatable/equatable.dart';
import '../../../domain/entities/qr_session.dart';

sealed class QrSessionState extends Equatable {
  const QrSessionState();

  @override
  List<Object?> get props => [];
}

class QrInitial extends QrSessionState {
  const QrInitial();
}

class QrGenerating extends QrSessionState {
  const QrGenerating();
}

class QrActive extends QrSessionState {
  final QrSession session;
  final int secondsLeft;
  final int totalSeconds;

  const QrActive({
    required this.session,
    required this.secondsLeft,
    this.totalSeconds = 120,
  });

  double get progress => totalSeconds > 0 ? (secondsLeft / totalSeconds).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [session, secondsLeft, totalSeconds];
}

class QrExpired extends QrSessionState {
  final QrSession? lastSession;

  const QrExpired([this.lastSession]);

  @override
  List<Object?> get props => [lastSession];
}

class QrError extends QrSessionState {
  final String message;

  const QrError(this.message);

  @override
  List<Object?> get props => [message];
}
