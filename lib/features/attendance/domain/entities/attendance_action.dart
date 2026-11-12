/// Represents the action performed during an attendance mark operation.
enum AttendanceAction {
  checkIn,
  checkOut;

  static AttendanceAction fromString(String value) {
    final lower = value.toLowerCase().replaceAll('-', '_');
    if (lower == 'check_out' || lower == 'checkout') {
      return AttendanceAction.checkOut;
    }
    return AttendanceAction.checkIn;
  }

  String get displayName {
    switch (this) {
      case AttendanceAction.checkIn:
        return 'Check In';
      case AttendanceAction.checkOut:
        return 'Check Out';
    }
  }

  String get pastTense {
    switch (this) {
      case AttendanceAction.checkIn:
        return 'Checked In';
      case AttendanceAction.checkOut:
        return 'Checked Out';
    }
  }
}

