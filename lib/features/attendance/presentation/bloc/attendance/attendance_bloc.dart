import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/entities/qr_payload.dart';
import '../../../domain/usecases/get_today_status_usecase.dart';
import '../../../domain/usecases/mark_attendance_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetTodayStatusUseCase getTodayStatusUseCase;
  final MarkAttendanceUseCase markAttendanceUseCase;

  AttendanceRecord? _lastKnownTodayRecord;

  AttendanceBloc({
    required this.getTodayStatusUseCase,
    required this.markAttendanceUseCase,
  }) : super(const AttendanceInitial()) {
    on<TodayStatusRequested>(_onTodayStatusRequested);
    on<QrScanned>(_onQrScanned, transformer: droppable());
    on<AttendanceReset>(_onAttendanceReset);
  }

  Future<void> _onTodayStatusRequested(
    TodayStatusRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading('Checking today\'s status...'));

    final result = await getTodayStatusUseCase(event.employeeId);
    if (result.isSuccess) {
      _lastKnownTodayRecord = result.data;
      emit(TodayStatusLoaded(record: result.data));
    } else {
      emit(AttendanceFailure(result.failure));
    }
  }

  Future<void> _onQrScanned(
    QrScanned event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const SubmittingAttendance('Verifying QR code & recording attendance...'));

    // 1. Validate QR payload
    late final QrPayload payload;
    try {
      payload = QrPayload.parse(event.rawQrCode);
    } on QrInvalidException catch (e) {
      emit(AttendanceFailure(QrInvalidFailure(e.message)));
      return;
    } catch (_) {
      emit(const AttendanceFailure(QrInvalidFailure()));
      return;
    }

    // 2. Submit authoritative scan to Supabase RPC
    final result = await markAttendanceUseCase(
      sessionId: payload.sessionId,
      token: payload.token,
      lat: event.lat,
      lng: event.lng,
    );

    if (result.isSuccess) {
      _lastKnownTodayRecord = result.data.record;
      emit(AttendanceSuccess(
        action: result.data.action,
        record: result.data.record,
      ));
    } else {
      emit(AttendanceFailure(result.failure));
    }
  }

  void _onAttendanceReset(
    AttendanceReset event,
    Emitter<AttendanceState> emit,
  ) {
    emit(TodayStatusLoaded(record: _lastKnownTodayRecord));
  }
}
