import 'package:equatable/equatable.dart';
import '../../../domain/entities/admin_attendance_record.dart';

sealed class AdminRecordsState extends Equatable {
  const AdminRecordsState();

  @override
  List<Object?> get props => [];
}

class AdminRecordsInitial extends AdminRecordsState {
  const AdminRecordsInitial();
}

class AdminRecordsLoading extends AdminRecordsState {
  const AdminRecordsLoading();
}

class AdminRecordsLoaded extends AdminRecordsState {
  final List<AdminAttendanceRecord> records;
  final bool hasMore;
  final bool isFetchingNextPage;
  final String? selectedDate;
  final String searchQuery;
  final int todayCheckIns;
  final int todayCompleted;

  const AdminRecordsLoaded({
    required this.records,
    this.hasMore = false,
    this.isFetchingNextPage = false,
    this.selectedDate,
    this.searchQuery = '',
    this.todayCheckIns = 0,
    this.todayCompleted = 0,
  });

  AdminRecordsLoaded copyWith({
    List<AdminAttendanceRecord>? records,
    bool? hasMore,
    bool? isFetchingNextPage,
    String? Function()? selectedDate,
    String? searchQuery,
    int? todayCheckIns,
    int? todayCompleted,
  }) {
    return AdminRecordsLoaded(
      records: records ?? this.records,
      hasMore: hasMore ?? this.hasMore,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      selectedDate: selectedDate != null ? selectedDate() : this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
      todayCheckIns: todayCheckIns ?? this.todayCheckIns,
      todayCompleted: todayCompleted ?? this.todayCompleted,
    );
  }

  @override
  List<Object?> get props => [
        records,
        hasMore,
        isFetchingNextPage,
        selectedDate,
        searchQuery,
        todayCheckIns,
        todayCompleted,
      ];
}

class AdminRecordsError extends AdminRecordsState {
  final String message;

  const AdminRecordsError(this.message);

  @override
  List<Object?> get props => [message];
}
