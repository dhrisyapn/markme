import '../../domain/entities/qr_session.dart';

class QrSessionModel extends QrSession {
  const QrSessionModel({
    required super.sessionId,
    required super.token,
    required super.expiresInSeconds,
    required super.expiresAt,
  });

  factory QrSessionModel.fromJson(Map<String, dynamic> json) {
    return QrSessionModel(
      sessionId: json['session_id'] as String,
      token: json['token'] as String,
      expiresInSeconds: (json['expires_in_seconds'] as num?)?.toInt() ?? 120,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'token': token,
      'expires_in_seconds': expiresInSeconds,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

