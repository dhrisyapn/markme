import 'dart:convert';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/employee_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<EmployeeProfile, Failure>> login({
    required String email,
    required String password,
  }) async {
    try {
      final token = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Parse user UUID from the JWT access token payload
      final userId = _extractUserIdFromJwt(token.accessToken);
      if (userId == null) {
        return const ErrorResult(ServerFailure('Malformed authentication token.'));
      }

      // Persist tokens immediately so that subsequent requests have the Bearer token
      // available both in SecureTokenStorage (for AuthInterceptor) and explicitly
      await localDataSource.saveTokens(token);

      try {
        // Fetch employee profile from public.employees table
        final profile = await remoteDataSource.getEmployeeProfile(
          userId,
          accessToken: token.accessToken,
        );

        // Persist profile to local encrypted storage
        await localDataSource.saveProfile(profile);

        return Success(profile);
      } catch (e) {
        // If profile fetching fails, wipe saved tokens to avoid corrupted auth state
        await localDataSource.clearSession();
        rethrow;
      }
    } catch (e) {
      return ErrorResult(ErrorMapper.map(e));
    }
  }

  @override
  Future<Result<EmployeeProfile, Failure>> restoreSession() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ErrorResult(UnauthorizedFailure('No saved session.'));
      }

      // Read from local encrypted cache first for instant startup
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        _tryBackgroundProfileRefresh(cachedProfile.id, accessToken: token);
        return Success(cachedProfile);
      }

      // If no cached profile, extract ID from token and fetch from remote
      final userId = _extractUserIdFromJwt(token);
      if (userId == null) {
        await localDataSource.clearSession();
        return const ErrorResult(UnauthorizedFailure('Invalid saved session.'));
      }

      final freshProfile = await remoteDataSource.getEmployeeProfile(
        userId,
        accessToken: token,
      );
      await localDataSource.saveProfile(freshProfile);
      return Success(freshProfile);
    } catch (e) {
      return ErrorResult(ErrorMapper.map(e));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore remote network failures on logout
    } finally {
      await localDataSource.clearSession();
    }
    return const Success(null);
  }

  @override
  Future<Result<EmployeeProfile, Failure>> getProfile(String userId) async {
    try {
      final token = await localDataSource.getAccessToken();
      final profile = await remoteDataSource.getEmployeeProfile(
        userId,
        accessToken: token,
      );
      await localDataSource.saveProfile(profile);
      return Success(profile);
    } catch (e) {
      return ErrorResult(ErrorMapper.map(e));
    }
  }

  void _tryBackgroundProfileRefresh(String userId, {String? accessToken}) {
    remoteDataSource
        .getEmployeeProfile(userId, accessToken: accessToken)
        .then((profile) {
      localDataSource.saveProfile(profile);
    }).catchError((_) {
      // Silent catch on background refresh failure
    });
  }

  String? _extractUserIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload) as Map<String, dynamic>;
      return data['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
