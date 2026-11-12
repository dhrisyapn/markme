import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/features/attendance/domain/entities/attendance_action.dart';
import 'package:markme/features/attendance/domain/entities/attendance_record.dart';
import 'package:markme/features/attendance/domain/usecases/get_today_status_usecase.dart';
import 'package:markme/features/attendance/domain/usecases/mark_attendance_usecase.dart';
import 'package:markme/features/attendance/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:markme/features/attendance/presentation/bloc/attendance/attendance_event.dart';
import 'package:markme/features/attendance/presentation/bloc/attendance/attendance_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTodayStatusUseCase extends Mock implements GetTodayStatusUseCase {}
class MockMarkAttendanceUseCase extends Mock implements MarkAttendanceUseCase {}

void main() {
  late MockGetTodayStatusUseCase mockGetTodayStatusUseCase;
  late MockMarkAttendanceUseCase mockMarkAttendanceUseCase;
  late AttendanceBloc attendanceBloc;

  final tRecord = AttendanceRecord(
    id: 'rec-1',
    employeeId: 'emp-1',
    workDate: '2026-11-12',
    checkInAt: DateTime.parse('2026-11-12T09:00:00Z'),
    checkInLat: 12.9716,
    checkInLng: 77.5946,
  );

  setUp(() {
    mockGetTodayStatusUseCase = MockGetTodayStatusUseCase();
    mockMarkAttendanceUseCase = MockMarkAttendanceUseCase();
    attendanceBloc = AttendanceBloc(
      getTodayStatusUseCase: mockGetTodayStatusUseCase,
      markAttendanceUseCase: mockMarkAttendanceUseCase,
    );
  });

  tearDown(() {
    attendanceBloc.close();
  });

  group('TodayStatusRequested', () {
    blocTest<AttendanceBloc, AttendanceState>(
      'emits [AttendanceLoading, TodayStatusLoaded] when getTodayStatus succeeds',
      build: () {
        when(() => mockGetTodayStatusUseCase('emp-1'))
            .thenAnswer((_) async => Success(tRecord));
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(const TodayStatusRequested('emp-1')),
      expect: () => [
        const AttendanceLoading('Checking today\'s status...'),
        TodayStatusLoaded(record: tRecord),
      ],
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [AttendanceLoading, AttendanceFailure] when getTodayStatus fails',
      build: () {
        when(() => mockGetTodayStatusUseCase('emp-1'))
            .thenAnswer((_) async => const ErrorResult(NetworkFailure()));
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(const TodayStatusRequested('emp-1')),
      expect: () => [
        const AttendanceLoading('Checking today\'s status...'),
        const AttendanceFailure(NetworkFailure()),
      ],
    );
  });

  group('QrScanned', () {
    const validQr = '{"v":1,"sid":"session-uuid","tok":"tok-hex"}';

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [SubmittingAttendance, AttendanceSuccess] on valid QR and successful check-in',
      build: () {
        when(() => mockMarkAttendanceUseCase(
              sessionId: 'session-uuid',
              token: 'tok-hex',
              lat: 12.9716,
              lng: 77.5946,
            )).thenAnswer((_) async => Success((action: AttendanceAction.checkIn, record: tRecord)));
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(const QrScanned(
        rawQrCode: validQr,
        lat: 12.9716,
        lng: 77.5946,
      )),
      expect: () => [
        const SubmittingAttendance('Verifying QR code & recording attendance...'),
        AttendanceSuccess(action: AttendanceAction.checkIn, record: tRecord),
      ],
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [SubmittingAttendance, AttendanceFailure] when QR payload is invalid',
      build: () => attendanceBloc,
      act: (bloc) => bloc.add(const QrScanned(
        rawQrCode: 'corrupted-qr-string',
        lat: 12.9716,
        lng: 77.5946,
      )),
      expect: () => [
        const SubmittingAttendance('Verifying QR code & recording attendance...'),
        isA<AttendanceFailure>().having((s) => s.failure, 'failure', isA<QrInvalidFailure>()),
      ],
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [SubmittingAttendance, AttendanceFailure] when QR code has expired on server',
      build: () {
        when(() => mockMarkAttendanceUseCase(
              sessionId: 'session-uuid',
              token: 'tok-hex',
              lat: 12.9716,
              lng: 77.5946,
            )).thenAnswer((_) async => const ErrorResult(QrExpiredFailure()));
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(const QrScanned(
        rawQrCode: validQr,
        lat: 12.9716,
        lng: 77.5946,
      )),
      expect: () => [
        const SubmittingAttendance('Verifying QR code & recording attendance...'),
        const AttendanceFailure(QrExpiredFailure()),
      ],
    );
  });
}

