import 'package:intl/intl.dart';

/// Helper utility for parsing and formatting dates and times across the app.
class DateFormatter {
  const DateFormatter._();

  static final DateFormat _workDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormat = DateFormat('EEE, dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _fullDateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Returns current UTC work date string (yyyy-MM-dd).
  static String todayUtcString() {
    return _workDateFormat.format(DateTime.now().toUtc());
  }

  /// Converts DateTime to yyyy-MM-dd.
  static String formatWorkDate(DateTime dateTime) {
    return _workDateFormat.format(dateTime);
  }

  /// Converts ISO 8601 or DateTime to human-readable date (e.g. 'Thu, 12 Nov 2026').
  static String formatDisplayDate(dynamic date) {
    final parsed = _parseDateTime(date);
    if (parsed == null) return '--';
    return _displayDateFormat.format(parsed.toLocal());
  }

  /// Converts ISO 8601 or DateTime to local 12-hour time (e.g. '09:30 AM').
  static String formatTime(dynamic date) {
    final parsed = _parseDateTime(date);
    if (parsed == null) return '--';
    return _timeFormat.format(parsed.toLocal());
  }

  /// Converts ISO 8601 or DateTime to full date and time string.
  static String formatFullDateTime(dynamic date) {
    final parsed = _parseDateTime(date);
    if (parsed == null) return '--';
    return _fullDateTimeFormat.format(parsed.toLocal());
  }

  /// Calculates duration between check-in and check-out formatted as 'Xh Ym'.
  static String formatDuration(dynamic checkIn, dynamic checkOut) {
    final inTime = _parseDateTime(checkIn);
    final outTime = _parseDateTime(checkOut);
    if (inTime == null || outTime == null) return '--';

    final diff = outTime.difference(inTime);
    if (diff.isNegative) return '--';

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

