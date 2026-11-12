import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../models/auth_token_model.dart';
import '../models/employee_profile_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthSession({
    required AuthTokenModel token,
    required EmployeeProfileModel profile,
  });

  Future<void> saveTokens(AuthTokenModel token);

  Future<void> saveProfile(EmployeeProfileModel profile);

  Future<EmployeeProfileModel?> getCachedProfile();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureTokenStorage tokenStorage;
  final FlutterSecureStorage rawStorage;
  final AppDatabase appDatabase;

  const AuthLocalDataSourceImpl({
    required this.tokenStorage,
    required this.rawStorage,
    required this.appDatabase,
  });

  @override
  Future<void> saveTokens(AuthTokenModel token) async {
    await tokenStorage.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
  }

  @override
  Future<void> saveAuthSession({
    required AuthTokenModel token,
    required EmployeeProfileModel profile,
  }) async {
    await saveTokens(token);
    await saveProfile(profile);
  }

  @override
  Future<void> saveProfile(EmployeeProfileModel profile) async {
    final jsonStr = jsonEncode(profile.toJson());
    await rawStorage.write(key: AppConstants.keyUserProfile, value: jsonStr);
  }

  @override
  Future<EmployeeProfileModel?> getCachedProfile() async {
    final jsonStr = await rawStorage.read(key: AppConstants.keyUserProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return EmployeeProfileModel.fromJson(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<String?> getAccessToken() => tokenStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() => tokenStorage.getRefreshToken();

  @override
  Future<void> clearSession() async {
    await tokenStorage.clearTokens();
    await appDatabase.clearAll();
  }
}
