import 'package:equatable/equatable.dart';

sealed class AdminRecordsEvent extends Equatable {
  const AdminRecordsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial or reset fetch of attendance records.
class AdminRecordsFetchRequested extends AdminRecordsEvent {
  const AdminRecordsFetchRequested();
}

/// Loads subsequent page of 20 records when user scrolls near the bottom.
class AdminRecordsNextPageRequested extends AdminRecordsEvent {
  const AdminRecordsNextPageRequested();
}

/// User pulled to refresh the records list.
class AdminRecordsRefreshed extends AdminRecordsEvent {
  const AdminRecordsRefreshed();
}

/// Filter records by specific work date (yyyy-MM-dd) or null for all.
class AdminRecordsDateFilterChanged extends AdminRecordsEvent {
  final String? workDate;

  const AdminRecordsDateFilterChanged(this.workDate);

  @override
  List<Object?> get props => [workDate];
}

/// Search filter for employee name or employee code.
class AdminRecordsSearchChanged extends AdminRecordsEvent {
  final String query;

  const AdminRecordsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

