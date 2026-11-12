import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Domain entity representing an active admin-generated attendance QR session.
class QrSession extends Equatable {
  final String sessionId;
  final String token;
  final int expiresInSeconds;
  final DateTime expiresAt;

  const QrSession({
    required this.sessionId,
    required this.token,
    required this.expiresInSeconds,
    required this.expiresAt,
  });

  /// Standardized JSON string encoded inside the QR code.
  /// Format: `{"v":1,"sid":"<session_id>","tok":"<token>"}`
  String get payloadJson => jsonEncode({
        'v': 1,
        'sid': sessionId,
        'tok': token,
      });

  /// Checks if the QR session has expired based on current device clock
  /// (Authoritative check is always enforced on the backend).
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt.toUtc());

  /// Returns remaining seconds left.
  int get remainingSeconds {
    final diff = expiresAt.toUtc().difference(DateTime.now().toUtc()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  @override
  List<Object?> get props => [sessionId, token, expiresInSeconds, expiresAt];
}

