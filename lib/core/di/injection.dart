import 'package:get_it/get_it.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/app_database.dart';
import '../storage/secure_token_storage.dart';
import '../utils/location_service.dart';

final GetIt sl = GetIt.instance;

/// Configures dependency injection container with core services and infrastructure singletons.
Future<void> configureDependencies() async {
  // 1. Storage
  final tokenStorage = SecureTokenStorage.defaultInstance();
  sl.registerLazySingleton<SecureTokenStorage>(() => tokenStorage);

  final database = AppDatabase.instance;
  sl.registerLazySingleton<AppDatabase>(() => database);

  // 2. Platform Utilities
  sl.registerLazySingleton<LocationService>(() => const LocationService());

  // 3. Network Infrastructure
  final authInterceptor = AuthInterceptor(
    tokenStorage: sl<SecureTokenStorage>(),
  );
  sl.registerLazySingleton<AuthInterceptor>(() => authInterceptor);

  final dioClient = DioClient(
    authInterceptor: sl<AuthInterceptor>(),
  );
  sl.registerLazySingleton<DioClient>(() => dioClient);
}

