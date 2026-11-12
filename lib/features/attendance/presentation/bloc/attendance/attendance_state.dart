import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/attendance_action.dart';
import '../../../domain/entities/attendance_record.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  final String message;

  const AttendanceLoading([this.message = 'Loading attendance status...']);

  @override
  List<Object?> get props => [message];
}

class TodayStatusLoaded extends AttendanceState {
  final AttendanceRecord? record;

  const TodayStatusLoaded({this.record});

  /// Next recommended action for the employee button.
  AttendanceAction get nextAction {
    if (record == null) {
      return AttendanceAction.checkIn;
    }
    if (record!.checkOutAt == null) {
      return AttendanceAction.checkOut;
    }
    return AttendanceAction.checkIn;
  }

  bool get isCompleted => record?.isCompleted ?? false;
  bool get isCheckedIn => record?.isCheckedIn ?? false;

  @override
  List<Object?> get props => [record];
}

class SubmittingAttendance extends AttendanceState {
  final String message;

  const SubmittingAttendance([this.message = 'Verifying QR session & recording attendance...']);

  @override
  List<Object?> get props => [message];
}

class AttendanceSuccess extends AttendanceState {
  final AttendanceAction action;
  final AttendanceRecord record;

  const AttendanceSuccess({
    required this.action,
    required this.record,
  });

  @override
  List<Object?> get props => [action, record];
}

class AttendanceFailure extends AttendanceState {
  final Failure failure;

  const AttendanceFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
