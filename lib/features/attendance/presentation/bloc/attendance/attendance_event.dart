import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Request today's attendance record to configure UI check-in/out state.
class TodayStatusRequested extends AttendanceEvent {
  final String employeeId;

  const TodayStatusRequested(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

/// Dispatched when the camera scanner reads a QR code with GPS coordinates.
class QrScanned extends AttendanceEvent {
  final String rawQrCode;
  final double lat;
  final double lng;

  const QrScanned({
    required this.rawQrCode,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [rawQrCode, lat, lng];
}

/// Resets attendance status back to idle or today's loaded state.
class AttendanceReset extends AttendanceEvent {
  const AttendanceReset();
}

