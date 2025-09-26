import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/user.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient();

  /// 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    try {
      final response = await _dioClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        if (nickname != null) 'nickname': nickname,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('회원가입 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('회원가입 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleAuthError(e);
    }
  }

  /// 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('로그인 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleAuthError(e);
    }
  }

  /// 소셜 로그인
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? device,
    String? nonce,
  }) async {
    try {
      final response = await _dioClient.dio.post('/auth/social-login', data: {
        'provider': provider,
        if (idToken != null) 'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        if (device != null) 'device': device,
        if (nonce != null) 'nonce': nonce,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('소셜 로그인 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('소셜 로그인 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleAuthError(e);
    }
  }

  /// 토큰 갱신
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('토큰 갱신 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('토큰 갱신 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleAuthError(e);
    }
  }

  /// 에러 처리
  Exception _handleAuthError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? '인증 오류가 발생했습니다';
        return Exception(message);
      }
    }
    return Exception('네트워크 오류가 발생했습니다');
  }
}