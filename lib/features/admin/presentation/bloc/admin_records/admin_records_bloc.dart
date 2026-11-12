import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:markme/core/utils/date_formatter.dart';
import '../../../domain/entities/admin_attendance_record.dart';
import '../../../domain/usecases/get_all_attendance_records_usecase.dart';
import 'admin_records_event.dart';
import 'admin_records_state.dart';

class AdminRecordsBloc extends Bloc<AdminRecordsEvent, AdminRecordsState> {
  final GetAllAttendanceRecordsUseCase getAllRecordsUseCase;
  static const int _pageSize = 20;

  String? _currentDateFilter;
  String _currentSearchQuery = '';

  AdminRecordsBloc({
    required this.getAllRecordsUseCase,
  }) : super(const AdminRecordsInitial()) {
    on<AdminRecordsFetchRequested>(_onFetchRequested);
    on<AdminRecordsNextPageRequested>(_onNextPageRequested);
    on<AdminRecordsRefreshed>(_onRefreshed);
    on<AdminRecordsDateFilterChanged>(_onDateFilterChanged);
    on<AdminRecordsSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetchRequested(
    AdminRecordsFetchRequested event,
    Emitter<AdminRecordsState> emit,
  ) async {
    emit(const AdminRecordsLoading());

    final result = await getAllRecordsUseCase(
      offset: 0,
      limit: _pageSize,
      workDate: _currentDateFilter,
      query: _currentSearchQuery,
    );

    if (result.isSuccess) {
      final records = result.data;
      final metrics = _calculateMetrics(records);

      emit(AdminRecordsLoaded(
        records: records,
        hasMore: records.length >= _pageSize,
        selectedDate: _currentDateFilter,
        searchQuery: _currentSearchQuery,
        todayCheckIns: metrics['checkIns'] ?? 0,
        todayCompleted: metrics['completed'] ?? 0,
      ));
    } else {
      emit(AdminRecordsError(result.failure.message));
    }
  }

  Future<void> _onNextPageRequested(
    AdminRecordsNextPageRequested event,
    Emitter<AdminRecordsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AdminRecordsLoaded ||
        currentState.isFetchingNextPage ||
        !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isFetchingNextPage: true));

    final result = await getAllRecordsUseCase(
      offset: currentState.records.length,
      limit: _pageSize,
      workDate: _currentDateFilter,
      query: _currentSearchQuery,
    );

    if (result.isSuccess) {
      final newRecords = result.data;
      final updatedList = List<AdminAttendanceRecord>.from(currentState.records)
        ..addAll(newRecords);
      final metrics = _calculateMetrics(updatedList);

      emit(currentState.copyWith(
        records: updatedList,
        hasMore: newRecords.length >= _pageSize,
        isFetchingNextPage: false,
        todayCheckIns: metrics['checkIns'] ?? 0,
        todayCompleted: metrics['completed'] ?? 0,
      ));
    } else {
      emit(currentState.copyWith(isFetchingNextPage: false));
    }
  }

  Future<void> _onRefreshed(
    AdminRecordsRefreshed event,
    Emitter<AdminRecordsState> emit,
  ) async {
    final result = await getAllRecordsUseCase(
      offset: 0,
      limit: _pageSize,
      workDate: _currentDateFilter,
      query: _currentSearchQuery,
    );

    if (result.isSuccess) {
      final records = result.data;
      final metrics = _calculateMetrics(records);

      emit(AdminRecordsLoaded(
        records: records,
        hasMore: records.length >= _pageSize,
        selectedDate: _currentDateFilter,
        searchQuery: _currentSearchQuery,
        todayCheckIns: metrics['checkIns'] ?? 0,
        todayCompleted: metrics['completed'] ?? 0,
      ));
    } else {
      emit(AdminRecordsError(result.failure.message));
    }
  }

  Future<void> _onDateFilterChanged(
    AdminRecordsDateFilterChanged event,
    Emitter<AdminRecordsState> emit,
  ) async {
    _currentDateFilter = event.workDate;
    add(const AdminRecordsFetchRequested());
  }

  Future<void> _onSearchChanged(
    AdminRecordsSearchChanged event,
    Emitter<AdminRecordsState> emit,
  ) async {
    _currentSearchQuery = event.query;
    add(const AdminRecordsFetchRequested());
  }

  Map<String, int> _calculateMetrics(List<AdminAttendanceRecord> records) {
    final today = DateFormatter.todayUtcString();
    int checkIns = 0;
    int completed = 0;

    for (final r in records) {
      if (r.workDate == today) {
        if (r.checkInAt != null) checkIns++;
        if (r.isCompleted) completed++;
      }
    }

    return {
      'checkIns': checkIns,
      'completed': completed,
    };
  }
}
