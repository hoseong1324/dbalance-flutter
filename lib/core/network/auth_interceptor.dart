import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // X-Session-Token 헤더 추가
      final sessionToken = await _storage.getSessionToken();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        options.headers['X-Session-Token'] = sessionToken;
      }

      // Authorization 헤더 추가 (로그인된 경우)
      final accessToken = await _storage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      if (kDebugMode) {
        debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
        debugPrint('Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('Data: ${options.data}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Request interceptor error: $e');
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        // Refresh token으로 토큰 갱신 시도
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final dio = Dio();
          final response = await dio.post(
            'http://211.56.253.181:3000/api/v1/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

          if (response.statusCode == 200) {
            final data = response.data;
            if (data is Map<String, dynamic> && data.containsKey('data')) {
              final authData = data['data'];
              await _storage.saveTokens(
                authData['accessToken'],
                authData['refreshToken'],
              );
              await _storage.saveUser(authData['user']);

              // 원래 요청 재시도
              final retryResponse = await _retryRequest(err.requestOptions);
              _isRefreshing = false;
              handler.resolve(retryResponse);
              return;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Token refresh failed: $e');
        }
      }

      // Refresh 실패 시 토큰 삭제 및 로그아웃
      await _storage.clearAllTokens();
      _isRefreshing = false;
    }

    handler.next(err);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    return await dio.fetch(requestOptions);
  }
}
