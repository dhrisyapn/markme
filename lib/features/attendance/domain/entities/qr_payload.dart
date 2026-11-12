import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../../../core/error/exceptions.dart';

/// Validated payload extracted from a scanned MarkMe attendance QR code.
/// Expected schema: `{"v": 1, "sid": "<session_uuid>", "tok": "<auth_token>"}`
class QrPayload extends Equatable {
  final int version;
  final String sessionId;
  final String token;

  const QrPayload({
    required this.version,
    required this.sessionId,
    required this.token,
  });

  /// Factory parser that validates JSON structure and required attributes.
  /// Throws [QrInvalidException] if the QR code does not match the protocol.
  factory QrPayload.parse(String rawValue) {
    if (rawValue.trim().isEmpty) {
      throw const QrInvalidException('QR code is empty');
    }

    try {
      final dynamic decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        throw const QrInvalidException('Malformed QR payload: not a JSON object');
      }

      final version = decoded['v'];
      final sessionId = decoded['sid']?.toString().trim();
      final token = decoded['tok']?.toString().trim();

      if (version == null || version != 1) {
        throw const QrInvalidException('Unsupported QR code version');
      }

      if (sessionId == null || sessionId.isEmpty) {
        throw const QrInvalidException('Missing session ID in QR code');
      }

      if (token == null || token.isEmpty) {
        throw const QrInvalidException('Missing token in QR code');
      }

      return QrPayload(
        version: version is int ? version : int.parse(version.toString()),
        sessionId: sessionId,
        token: token,
      );
    } on QrInvalidException {
      rethrow;
    } catch (e) {
      throw QrInvalidException('Failed to parse QR payload: ${e.toString()}');
    }
  }

  /// Exports payload back to standard JSON string.
  String toJsonString() {
    return jsonEncode({
      'v': version,
      'sid': sessionId,
      'tok': token,
    });
  }

  @override
  List<Object?> get props => [version, sessionId, token];
}

