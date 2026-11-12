import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import '../config/env_config.dart';
import '../storage/secure_token_storage.dart';

/// Interceptor that handles Supabase API key injection, Bearer JWT authorization,
/// and automatic single-attempt token refreshing on HTTP 401 responses.
class AuthInterceptor extends QueuedInterceptor {
  final SecureTokenStorage tokenStorage;
  final Dio _refreshDio;
  final FutureOr<void> Function()? onSessionExpired;

  AuthInterceptor({
    required this.tokenStorage,
    Dio? refreshDio,
    this.onSessionExpired,
  })  : _refreshDio = refreshDio ??
            Dio(
              BaseOptions(
                baseUrl: EnvConfig.supabaseUrl,
                connectTimeout: AppConstants.connectTimeout,
                receiveTimeout: AppConstants.receiveTimeout,
                headers: {
                  'apikey': EnvConfig.supabaseAnonKey,
                  'Content-Type': 'application/json',
                },
              ),
            );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Ensure Supabase apikey is present
    if (!options.headers.containsKey('apikey')) {
      options.headers['apikey'] = EnvConfig.supabaseAnonKey;
    }

    // 2. Inject Bearer access token if available and not already provided
    if (!options.headers.containsKey('Authorization')) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Do not attempt token refresh for authentication endpoints (login / refresh itself)
    final isAuthEndpoint = requestOptions.path.contains('/auth/v1/token');

    if (response?.statusCode == 401 && !isAuthEndpoint) {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh with Supabase Auth
          final refreshResponse = await _refreshDio.post(
            AppConstants.authRefreshGrant,
            data: {'refresh_token': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data is Map) {
            final data = refreshResponse.data as Map<String, dynamic>;
            final newAccessToken = data['access_token'] as String?;
            final newRefreshToken = data['refresh_token'] as String?;

            if (newAccessToken != null && newRefreshToken != null) {
              await tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry original request with fresh token
              final clonedHeaders = Map<String, dynamic>.from(requestOptions.headers);
              clonedHeaders['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await _refreshDio.request(
                requestOptions.path,
                options: Options(
                  method: requestOptions.method,
                  headers: clonedHeaders,
                  responseType: requestOptions.responseType,
                  contentType: requestOptions.contentType,
                ),
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
              );

              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Refresh failed - session is irreversibly expired
        }
      }

      // If refresh failed or was unavailable, clear auth state & notify
      await tokenStorage.clearTokens();
      if (onSessionExpired != null) {
        await onSessionExpired!();
      }
    }

    return handler.next(err);
  }
}
