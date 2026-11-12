import 'package:equatable/equatable.dart';
import '../../../domain/entities/attendance_record.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<AttendanceRecord> records;
  final bool isOffline;

  const HistoryLoaded({
    required this.records,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [records, isOffline];
}

class HistoryError extends HistoryState {
  final String message;
  final List<AttendanceRecord>? cachedRecords;

  const HistoryError({
    required this.message,
    this.cachedRecords,
  });

  @override
  List<Object?> get props => [message, cachedRecords];
}
