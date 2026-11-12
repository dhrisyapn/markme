import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/create_qr_session_usecase.dart';
import '../../features/admin/domain/usecases/get_all_attendance_records_usecase.dart';
import '../../features/admin/presentation/bloc/admin_records/admin_records_bloc.dart';
import '../../features/admin/presentation/bloc/qr_session/qr_session_bloc.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/app_database.dart';
import '../storage/secure_token_storage.dart';
import '../utils/location_service.dart';

final GetIt sl = GetIt.instance;

/// Configures dependency injection container with core services, repositories, use cases, and BLoCs.
Future<void> configureDependencies() async {
  // 1. Storage & Database
  const rawStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => rawStorage);

  final tokenStorage = SecureTokenStorage(rawStorage);
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

  // 4. Feature: Auth
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      tokenStorage: sl<SecureTokenStorage>(),
      rawStorage: sl<FlutterSecureStorage>(),
      appDatabase: sl<AppDatabase>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<RestoreSessionUseCase>(() => RestoreSessionUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));

  // BLoC
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      restoreSessionUseCase: sl<RestoreSessionUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ),
  );

  // 5. Feature: Admin
  // Data Source & Repository
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<CreateQrSessionUseCase>(
    () => CreateQrSessionUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton<GetAllAttendanceRecordsUseCase>(
    () => GetAllAttendanceRecordsUseCase(sl<AdminRepository>()),
  );

  // BLoCs
  sl.registerFactory<QrSessionBloc>(
    () => QrSessionBloc(
      createQrSessionUseCase: sl<CreateQrSessionUseCase>(),
    ),
  );
  sl.registerFactory<AdminRecordsBloc>(
    () => AdminRecordsBloc(
      getAllRecordsUseCase: sl<GetAllAttendanceRecordsUseCase>(),
    ),
  );
}
