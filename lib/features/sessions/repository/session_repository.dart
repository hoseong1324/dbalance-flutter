import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/session_info.dart';

class SessionRepository {
  final DioClient _dioClient = DioClient();

  /// 게스트 세션 생성
  Future<SessionInfo> createGuestSession({String? deviceFingerprint}) async {
    try {
      final response = await _dioClient.dio.post('/sessions/guest', data: {
        if (deviceFingerprint != null) 'deviceFingerprint': deviceFingerprint,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return SessionInfo.fromJson(data['data']);
        } else {
          return SessionInfo.fromJson(data);
        }
      } else {
        throw Exception('게스트 세션 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('게스트 세션 생성 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleSessionError(e);
    }
  }

  /// 하트비트
  Future<bool> heartbeat() async {
    try {
      final response = await _dioClient.dio.patch('/sessions/heartbeat');

      if (response.statusCode == 200) {
        return true;
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