/// Environment configuration loaded at compile-time via --dart-define.
///
/// Example execution:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=https://<your-ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<your-key>
/// ```
class EnvConfig {
  const EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  /// Helper to check if placeholder credentials are still present.
  static bool get isConfigured =>
      supabaseUrl != 'https://placeholder.supabase.co' &&
      supabaseAnonKey != 'placeholder-anon-key';
}

