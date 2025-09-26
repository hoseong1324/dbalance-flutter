import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isRefreshing = false;
  final List<RequestOptions> _requestQueue = [];

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConfig.baseUrl}/api/${AppConfig.apiVersion}',
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _ErrorInterceptor(this),
      if (kDebugMode) _LogInterceptor(),
    ]);
  }

  Future<void> _refreshToken() async {
    if (_isRefreshing) return;
    
    _isRefreshing = true;
    
    try {
      final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refreshToken == null) {
        throw Exception('Refresh token not found');
      }

      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: AppConfig.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConfig.refreshTokenKey, value: data['refreshToken']);
        
        // 큐에 있는 요청들을 재시도
        await _retryQueuedRequests();
      }
    } catch (e) {
      // 리프레시 실패 시 로그아웃 처리
      await _clearTokens();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _retryQueuedRequests() async {
    final requests = List<RequestOptions>.from(_requestQueue);
    _requestQueue.clear();

    for (final request in requests) {
      try {
        await _dio.fetch(request);
      } catch (e) {
        if (kDebugMode) {
          print('Retry failed for ${request.path}: $e');
        }
      }
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
  }

  void addToQueue(RequestOptions request) {
    _requestQueue.add(request);
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Session Token 추가
    final sessionToken = await _storage.read(key: AppConfig.sessionTokenKey);
    if (sessionToken != null && sessionToken.isNotEmpty) {
      options.headers['X-Session-Token'] = sessionToken;
    }

    // Access Token 추가
    final accessToken = await _storage.read(key: AppConfig.accessTokenKey);
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  final ApiClient _apiClient;

  _ErrorInterceptor(this._apiClient);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await _apiClient._refreshToken();
        
        // 원래 요청을 재시도
        final request = err.requestOptions;
        final response = await _apiClient.dio.fetch(request);
        handler.resolve(response);
        return;
      } catch (e) {
        // 리프레시 실패 시 큐에 추가
        _apiClient.addToQueue(err.requestOptions);
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print('Message: ${err.message}');
      if (err.response?.data != null) {
        print('Response: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}
