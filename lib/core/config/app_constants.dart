/// Application-wide constants including timeouts, storage keys, and Supabase REST endpoints.
class AppConstants {
  const AppConstants._();

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Storage Keys (Secure Storage)
  static const String keyAccessToken = 'supabase_access_token';
  static const String keyRefreshToken = 'supabase_refresh_token';
  static const String keyUserProfile = 'cached_user_profile';

  // SQLite Config
  static const String databaseName = 'markme_local.db';
  static const int databaseVersion = 1;
  static const String tableAttendanceRecords = 'local_attendance_records';

  // QR Session
  static const int qrSessionDurationSeconds = 120; // 2 minutes

  // GPS Accuracy & Timeout
  static const Duration locationTimeout = Duration(seconds: 10);

  // Supabase PostgREST & Auth Endpoints
  static const String authPasswordGrant = '/auth/v1/token?grant_type=password';
  static const String authRefreshGrant = '/auth/v1/token?grant_type=refresh_token';
  static const String authLogout = '/auth/v1/logout';

  static const String endpointEmployees = '/rest/v1/employees';
  static const String endpointAttendanceRecords = '/rest/v1/attendance_records';
  static const String rpcCreateAttendanceSession = '/rest/v1/rpc/create_attendance_session';
  static const String rpcMarkAttendance = '/rest/v1/rpc/mark_attendance';
}

