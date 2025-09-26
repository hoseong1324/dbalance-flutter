import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../dto/session_dto.dart';

class SessionRepository {
  final ApiClient _apiClient = ApiClient();

  /// 게스트 세션 발급
  Future<CreateGuestSessionResponse> createGuestSession(CreateGuestSessionRequest request) async {
    try {
      final response = await _apiClient.dio.post('/sessions/guest', data: request.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateGuestSessionResponse.fromJson(response.data);
      } else {
        throw Exception('게스트 세션 발급 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('게스트 세션 발급 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleSessionError(e);
    }
  }

  /// 하트비트
  Future<HeartbeatResponse> heartbeat() async {
    try {
      final response = await _apiClient.dio.patch('/sessions/heartbeat');
      
      if (response.statusCode == 200) {
        return HeartbeatResponse.fromJson(response.data);
      } else {
        throw Exception('하트비트 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('하트비트 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleSessionError(e);
    }
  }

  /// 동일 기기 후보 세션 조회
  Future<List<ClaimableSession>> getClaimableSessions(String deviceFingerprint) async {
    try {
      final response = await _apiClient.dio.get('/sessions/claimables', queryParameters: {
        'deviceFingerprint': deviceFingerprint,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ClaimableSession.fromJson(json)).toList();
      } else {
        throw Exception('후보 세션 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('후보 세션 조회 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleSessionError(e);
    }
  }

  /// 세션 선택 클레임
  Future<ClaimResponse> claimSessions(ClaimSessionsRequest request) async {
    try {
      final response = await _apiClient.dio.post('/sessions/claim', data: request.toJson());
      
      if (response.statusCode == 200) {
        return ClaimResponse.fromJson(response.data);
      } else {
        throw Exception('세션 클레임 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('세션 클레임 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleSessionError(e);
    }
  }

  /// 복구 코드로 클레임
  Future<ClaimResponse> claimByCode(ClaimByCodeRequest request) async {
    try {
      final response = await _apiClient.dio.post('/sessions/claim-by-code', data: request.toJson());
      
      if (response.statusCode == 200) {
        return ClaimResponse.fromJson(response.data);
      } else {
        throw Exception('복구 코드 클레임 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('복구 코드 클레임 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleSessionError(e);
    }
  }

  /// 에러 처리
  Exception _handleSessionError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? '세션 오류가 발생했습니다';
        return Exception(message);
      }
    }
    return Exception('네트워크 오류가 발생했습니다');
  }
}
