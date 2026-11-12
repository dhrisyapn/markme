import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/features/attendance/domain/entities/attendance_record.dart';
import 'package:markme/features/attendance/domain/usecases/get_attendance_history_usecase.dart';
import 'package:markme/features/attendance/presentation/bloc/history/history_bloc.dart';
import 'package:markme/features/attendance/presentation/bloc/history/history_event.dart';
import 'package:markme/features/attendance/presentation/bloc/history/history_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAttendanceHistoryUseCase extends Mock implements GetAttendanceHistoryUseCase {}

void main() {
  late MockGetAttendanceHistoryUseCase mockUseCase;
  late HistoryBloc historyBloc;

  final tRecords = [
    AttendanceRecord(
      id: 'rec-1',
      employeeId: 'emp-1',
      workDate: '2026-11-12',
      checkInAt: DateTime.parse('2026-11-12T09:00:00Z'),
      checkInLat: 12.9716,
      checkInLng: 77.5946,
      checkOutAt: DateTime.parse('2026-11-12T17:00:00Z'),
      checkOutLat: 12.9716,
      checkOutLng: 77.5946,
    ),
  ];

  setUp(() {
    mockUseCase = MockGetAttendanceHistoryUseCase();
    historyBloc = HistoryBloc(getAttendanceHistoryUseCase: mockUseCase);
  });

  tearDown(() {
    historyBloc.close();
  });

  group('HistoryRequested', () {
    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryLoaded] when history fetch succeeds',
      build: () {
        when(() => mockUseCase('emp-1', forceRefresh: false))
            .thenAnswer((_) async => Success(tRecords));
        return historyBloc;
      },
      act: (bloc) => bloc.add(const HistoryRequested(employeeId: 'emp-1')),
      expect: () => [
        const HistoryLoading(),
        HistoryLoaded(records: tRecords),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [HistoryLoading, HistoryError] when history fetch fails',
      build: () {
        when(() => mockUseCase('emp-1', forceRefresh: false))
            .thenAnswer((_) async => const ErrorResult(NetworkFailure('Network offline')));
        return historyBloc;
      },
      act: (bloc) => bloc.add(const HistoryRequested(employeeId: 'emp-1')),
      expect: () => [
        const HistoryLoading(),
        const HistoryError(message: 'Network offline'),
      ],
    );
  });
}

