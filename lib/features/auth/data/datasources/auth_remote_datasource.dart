import 'package:dio/dio.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_token_model.dart';
import '../models/employee_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  });

  Future<EmployeeProfileModel> getEmployeeProfile(
    String userId, {
    String? accessToken,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      AppConstants.authPasswordGrant,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<EmployeeProfileModel> getEmployeeProfile(
    String userId, {
    String? accessToken,
  }) async {
    final options = accessToken != null
        ? Options(headers: {'Authorization': 'Bearer $accessToken'})
        : null;

    final response = await _client.get(
      AppConstants.endpointEmployees,
      queryParameters: {
        'id': 'eq.$userId',
        'select': '*',
      },
      options: options,
    );

    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return EmployeeProfileModel.fromJson(data.first as Map<String, dynamic>);
    }

    throw Exception('Profile not found for employee $userId');
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(AppConstants.authLogout);
    } catch (_) {
      // Best-effort remote revocation; local tokens will always be purged.
    }
  }
}

