import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../dto/auth_dto.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// 회원가입
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: request.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
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

  /// 로컬 로그인
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: request.toJson());
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
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
  Future<AuthResponse> socialLogin(SocialLoginRequest request) async {
    try {
      final response = await _apiClient.dio.post('/auth/social-login', data: request.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
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

  /// 토큰 재발급
  Future<AuthResponse> refresh(RefreshRequest request) async {
    try {
      final response = await _apiClient.dio.post('/auth/refresh', data: request.toJson());
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('토큰 재발급 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('토큰 재발급 오류: ${e.message}');
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
