import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Environment configuration reader.
///
/// Values are resolved in the following priority:
/// 1. Compile-time `--dart-define-from-file=.env` or `--dart-define` parameters (`PROJECT_URL` / `ANON_KEY`).
/// 2. Runtime `.env` asset loaded via [initialize].
/// 3. Default project credentials configured from `.env`.
class EnvConfig {
  const EnvConfig._();

  static const String _defaultUrl =
      'https://etbncyfmkasiohnqbevx.supabase.co';
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0Ym5jeWZta2FzaW9obnFiZXZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ0NjU5NDgsImV4cCI6MjExMDA0MTk0OH0.BmF3iY-64uBxvDYSq2z0hX-3VmaOMKZ25KZ2JCo1pNY';

  static String _runtimeUrl = '';
  static String _runtimeAnonKey = '';

  /// Loads configuration dynamically from the root `.env` asset if present.
  static Future<void> initialize() async {
    try {
      final envString = await rootBundle.loadString('.env');
      final lines = envString.split(RegExp(r'\r?\n'));
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final separatorIndex = trimmed.indexOf('=');
        if (separatorIndex == -1) continue;

        final key = trimmed.substring(0, separatorIndex).trim();
        final rawVal = trimmed.substring(separatorIndex + 1).trim();
        // Strip surrounding quotes if present
        final val = rawVal.replaceAll(RegExp(r'''^["']|["']$'''), '');

        if ((key == 'PROJECT_URL' || key == 'SUPABASE_URL') &&
            _runtimeUrl.isEmpty) {
          _runtimeUrl = val;
        } else if ((key == 'ANON_KEY' || key == 'SUPABASE_ANON_KEY') &&
            _runtimeAnonKey.isEmpty) {
          _runtimeAnonKey = val;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EnvConfig] .env asset not loaded or failed: $e');
      }
    }
  }

  /// Project REST / Auth base URL.
  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('PROJECT_URL');
    if (fromDefine.isNotEmpty && !fromDefine.contains('placeholder')) {
      return fromDefine;
    }

    const fromAlias = String.fromEnvironment('SUPABASE_URL');
    if (fromAlias.isNotEmpty && !fromAlias.contains('placeholder')) {
      return fromAlias;
    }

    if (_runtimeUrl.isNotEmpty) {
      return _runtimeUrl;
    }

    return _defaultUrl;
  }

  /// Public anonymous API key.
  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('ANON_KEY');
    if (fromDefine.isNotEmpty && !fromDefine.contains('placeholder')) {
      return fromDefine;
    }

    const fromAlias = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromAlias.isNotEmpty && !fromAlias.contains('placeholder')) {
      return fromAlias;
    }

    if (_runtimeAnonKey.isNotEmpty) {
      return _runtimeAnonKey;
    }

    return _defaultAnonKey;
  }

  /// Helper to check if credentials are configured.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('placeholder') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('placeholder');
}
