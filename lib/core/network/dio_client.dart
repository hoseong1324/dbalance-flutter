import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;
  final SecureStorage _storage = SecureStorage();

  Dio get dio => _dio;

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://211.56.253.181:3000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(AuthInterceptor(_storage));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('🌐 $obj'),
      ));
    }
  }
}
