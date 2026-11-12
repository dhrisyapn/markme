import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/error/failures.dart';
import 'package:markme/core/error/result.dart';
import 'package:markme/core/utils/date_formatter.dart';
import 'package:markme/features/admin/domain/entities/admin_attendance_record.dart';
import 'package:markme/features/admin/domain/usecases/get_all_attendance_records_usecase.dart';
import 'package:markme/features/admin/presentation/bloc/admin_records/admin_records_bloc.dart';
import 'package:markme/features/admin/presentation/bloc/admin_records/admin_records_event.dart';
import 'package:markme/features/admin/presentation/bloc/admin_records/admin_records_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllAttendanceRecordsUseCase extends Mock implements GetAllAttendanceRecordsUseCase {}

void main() {
  late MockGetAllAttendanceRecordsUseCase mockGetAllRecordsUseCase;
  late AdminRecordsBloc adminRecordsBloc;

  final today = DateFormatter.todayUtcString();
  final testRecords = [
    AdminAttendanceRecord(
      id: 'rec-1',
      employeeId: 'emp-1',
      employeeCode: 'EMP001',
      employeeName: 'Alice Johnson',
      workDate: today,
      checkInAt: DateTime.now().subtract(const Duration(hours: 4)),
      checkInLat: 12.9716,
      checkInLng: 77.5946,
      checkOutAt: DateTime.now(),
      checkOutLat: 12.9716,
      checkOutLng: 77.5946,
    ),
  ];

  setUp(() {
    mockGetAllRecordsUseCase = MockGetAllAttendanceRecordsUseCase();
    adminRecordsBloc = AdminRecordsBloc(
      getAllRecordsUseCase: mockGetAllRecordsUseCase,
    );
  });

  tearDown(() {
    adminRecordsBloc.close();
  });

  group('AdminRecordsBloc', () {
    test('initial state is AdminRecordsInitial', () {
      expect(adminRecordsBloc.state, const AdminRecordsInitial());
    });

    blocTest<AdminRecordsBloc, AdminRecordsState>(
      'emits [AdminRecordsLoading, AdminRecordsLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetAllRecordsUseCase(
              offset: 0,
              limit: 20,
              workDate: null,
              query: '',
            )).thenAnswer((_) async => Success(testRecords));
        return adminRecordsBloc;
      },
      act: (bloc) => bloc.add(const AdminRecordsFetchRequested()),
      expect: () => [
        const AdminRecordsLoading(),
        AdminRecordsLoaded(
          records: testRecords,
          hasMore: false,
          todayCheckIns: 1,
          todayCompleted: 1,
        ),
      ],
    );

    blocTest<AdminRecordsBloc, AdminRecordsState>(
      'emits [AdminRecordsLoading, AdminRecordsError] when fetch fails',
      build: () {
        when(() => mockGetAllRecordsUseCase(
              offset: 0,
              limit: 20,
              workDate: null,
              query: '',
            )).thenAnswer((_) async => const ErrorResult(NetworkFailure()));
        return adminRecordsBloc;
      },
      act: (bloc) => bloc.add(const AdminRecordsFetchRequested()),
      expect: () => [
        const AdminRecordsLoading(),
        const AdminRecordsError('No internet connection. Please check your network.'),
      ],
    );
  });
}

