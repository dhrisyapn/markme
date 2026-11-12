import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/exceptions.dart';
import 'package:markme/features/attendance/domain/entities/qr_payload.dart';

void main() {
  group('QrPayload', () {
    test('parses valid QR JSON payload correctly', () {
      const rawJson = '{"v":1,"sid":"sess-123-uuid","tok":"tok-abc-hex"}';
      final payload = QrPayload.parse(rawJson);

      expect(payload.version, 1);
      expect(payload.sessionId, 'sess-123-uuid');
      expect(payload.token, 'tok-abc-hex');
    });

    test('throws QrInvalidException when payload is empty', () {
      expect(() => QrPayload.parse('   '), throwsA(isA<QrInvalidException>()));
    });

    test('throws QrInvalidException when payload is not JSON', () {
      expect(() => QrPayload.parse('plain text string'), throwsA(isA<QrInvalidException>()));
    });

    test('throws QrInvalidException when version is unsupported', () {
      const invalidVersion = '{"v":2,"sid":"sess-123","tok":"tok-abc"}';
      expect(() => QrPayload.parse(invalidVersion), throwsA(isA<QrInvalidException>()));
    });

    test('throws QrInvalidException when sid is missing or empty', () {
      const missingSid = '{"v":1,"sid":"","tok":"tok-abc"}';
      expect(() => QrPayload.parse(missingSid), throwsA(isA<QrInvalidException>()));
    });

    test('throws QrInvalidException when tok is missing or empty', () {
      const missingTok = '{"v":1,"sid":"sess-123","tok":""}';
      expect(() => QrPayload.parse(missingTok), throwsA(isA<QrInvalidException>()));
    });
  });
}

