import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryRequested extends HistoryEvent {
  final String employeeId;
  final bool forceRefresh;

  const HistoryRequested({
    required this.employeeId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [employeeId, forceRefresh];
}

class HistoryRefreshed extends HistoryEvent {
  final String employeeId;

  const HistoryRefreshed({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

