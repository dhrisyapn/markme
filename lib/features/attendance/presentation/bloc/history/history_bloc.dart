import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_attendance_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;

  HistoryBloc({
    required this.getAttendanceHistoryUseCase,
  }) : super(const HistoryInitial()) {
    on<HistoryRequested>(_onHistoryRequested);
    on<HistoryRefreshed>(_onHistoryRefreshed);
  }

  Future<void> _onHistoryRequested(
    HistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    final result = await getAttendanceHistoryUseCase(
      event.employeeId,
      forceRefresh: event.forceRefresh,
    );

    if (result.isSuccess) {
      emit(HistoryLoaded(records: result.data));
    } else {
      emit(HistoryError(message: result.failure.message));
    }
  }

  Future<void> _onHistoryRefreshed(
    HistoryRefreshed event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await getAttendanceHistoryUseCase(
      event.employeeId,
      forceRefresh: true,
    );

    if (result.isSuccess) {
      emit(HistoryLoaded(records: result.data));
    } else {
      emit(HistoryError(message: result.failure.message));
    }
  }
}
