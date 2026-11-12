import 'package:equatable/equatable.dart';

sealed class QrSessionEvent extends Equatable {
  const QrSessionEvent();

  @override
  List<Object?> get props => [];
}

/// Request to create a new QR session via RPC with optional custom expiration in minutes.
class QrGenerateRequested extends QrSessionEvent {
  final int? durationMinutes;

  const QrGenerateRequested({this.durationMinutes});

  @override
  List<Object?> get props => [durationMinutes];
}

/// Periodic 1-second countdown tick.
class QrTicked extends QrSessionEvent {
  final int secondsLeft;

  const QrTicked(this.secondsLeft);

  @override
  List<Object?> get props => [secondsLeft];
}

/// Resets QR session to initial state.
class QrResetRequested extends QrSessionEvent {
  const QrResetRequested();
}

