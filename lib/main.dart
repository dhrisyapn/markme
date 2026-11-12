import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/env_config.dart';
import 'core/di/injection.dart';
import 'core/storage/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration (.env asset or defines)
  await EnvConfig.initialize();

  // Initialize Core Services & Singletons
  await configureDependencies();

  // Initialize SQLite Local Cache
  await AppDatabase.instance.init();

  runApp(const App());
}
