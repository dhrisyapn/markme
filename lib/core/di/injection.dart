import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/create_qr_session_usecase.dart';
import '../../features/admin/domain/usecases/get_all_attendance_records_usecase.dart';
import '../../features/admin/presentation/bloc/admin_records/admin_records_bloc.dart';
import '../../features/admin/presentation/bloc/qr_session/qr_session_bloc.dart';
import '../../features/attendance/data/datasources/attendance_local_datasource.dart';
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/get_attendance_history_usecase.dart';
import '../../features/attendance/domain/usecases/get_today_status_usecase.dart';
import '../../features/attendance/domain/usecases/mark_attendance_usecase.dart';
import '../../features/attendance/presentation/bloc/attendance/attendance_bloc.dart';
import '../../features/attendance/presentation/bloc/history/history_bloc.dart';
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

  // 6. Feature: Attendance (Employee)
  // Data Sources
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceImpl(sl<AppDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl<AttendanceRemoteDataSource>(),
      localDataSource: sl<AttendanceLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetTodayStatusUseCase>(
    () => GetTodayStatusUseCase(sl<AttendanceRepository>()),
  );
  sl.registerLazySingleton<MarkAttendanceUseCase>(
    () => MarkAttendanceUseCase(sl<AttendanceRepository>()),
  );
  sl.registerLazySingleton<GetAttendanceHistoryUseCase>(
    () => GetAttendanceHistoryUseCase(sl<AttendanceRepository>()),
  );

  // BLoCs
  sl.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      getTodayStatusUseCase: sl<GetTodayStatusUseCase>(),
      markAttendanceUseCase: sl<MarkAttendanceUseCase>(),
    ),
  );
  sl.registerFactory<HistoryBloc>(
    () => HistoryBloc(
      getAttendanceHistoryUseCase: sl<GetAttendanceHistoryUseCase>(),
    ),
  );
}
