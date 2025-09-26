import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/participant.dart';

class ParticipantsRepository {
  final ApiClient _apiClient = ApiClient();

  /// 참가자 생성
  Future<Participant> createParticipant({
    required String displayName,
    bool? defaultIsDrinker,
  }) async {
    try {
      final response = await _apiClient.dio.post('/participants', data: {
        'displayName': displayName,
        if (defaultIsDrinker != null) 'defaultIsDrinker': defaultIsDrinker,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Participant.fromJson(response.data);
      } else {
        throw Exception('참가자 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('참가자 생성 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleParticipantError(e);
    }
  }

  /// 참가자 조회
  Future<Participant> getParticipant(int id) async {
    try {
      final response = await _apiClient.dio.get('/participants/$id');
      
      if (response.statusCode == 200) {
        return Participant.fromJson(response.data);
      } else {
        throw Exception('참가자 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('참가자 조회 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleParticipantError(e);
    }
  }

  /// 참가자 검색
  Future<List<Participant>> searchParticipants(String keyword) async {
    try {
      final response = await _apiClient.dio.get('/participants', queryParameters: {
        'q': keyword,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Participant.fromJson(json)).toList();
      } else {
        throw Exception('참가자 검색 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('참가자 검색 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleParticipantError(e);
    }
  }

  /// 참가자 수정
  Future<Participant> updateParticipant(int id, {
    String? displayName,
    bool? defaultIsDrinker,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/participants/$id', data: {
        if (displayName != null) 'displayName': displayName,
        if (defaultIsDrinker != null) 'defaultIsDrinker': defaultIsDrinker,
      });
      
      if (response.statusCode == 200) {
        return Participant.fromJson(response.data);
      } else {
        throw Exception('참가자 수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('참가자 수정 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleParticipantError(e);
    }
  }

  /// 참가자 삭제
  Future<int> deleteParticipant(int id) async {
    try {
      final response = await _apiClient.dio.delete('/participants/$id');
      
      if (response.statusCode == 200) {
        return response.data['affected'] ?? 0;
      } else {
        throw Exception('참가자 삭제 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('참가자 삭제 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleParticipantError(e);
    }
  }

  /// 에러 처리
  Exception _handleParticipantError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? '참가자 관련 오류가 발생했습니다';
        return Exception(message);
      }
    }
    return Exception('네트워크 오류가 발생했습니다');
  }
}
