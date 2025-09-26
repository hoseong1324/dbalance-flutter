import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/room.dart';
import '../../../shared/models/participant.dart';

class RoomsRepository {
  final ApiClient _apiClient = ApiClient();

  /// 방 생성
  Future<Room> createRoom({
    required String name,
    String? date,
    String? inviteCode,
  }) async {
    try {
      final response = await _apiClient.dio.post('/rooms', data: {
        'name': name,
        if (date != null) 'date': date,
        if (inviteCode != null) 'inviteCode': inviteCode,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Room.fromJson(response.data);
      } else {
        throw Exception('방 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('방 생성 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleRoomError(e);
    }
  }

  /// 방 수정
  Future<Room> updateRoom(int roomId, {
    String? name,
    String? date,
    String? inviteCode,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/rooms/$roomId', data: {
        if (name != null) 'name': name,
        if (date != null) 'date': date,
        if (inviteCode != null) 'inviteCode': inviteCode,
      });
      
      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      } else {
        throw Exception('방 수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('방 수정 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleRoomError(e);
    }
  }

  /// 방 조회
  Future<Room> getRoom(int roomId) async {
    try {
      final response = await _apiClient.dio.get('/rooms/$roomId');
      
      if (response.statusCode == 200) {
        return Room.fromJson(response.data);
      } else {
        throw Exception('방 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('방 조회 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleRoomError(e);
    }
  }

  /// 라운드 목록 조회
  Future<List<Round>> getRounds(int roomId) async {
    try {
      final response = await _apiClient.dio.get('/rooms/$roomId/rounds');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Round.fromJson(json)).toList();
      } else {
        throw Exception('라운드 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('라운드 목록 조회 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleRoomError(e);
    }
  }

  /// 라운드 생성
  Future<Round> createRound(int roomId, {
    int? roundNumber,
    String? placeName,
    String? memo,
  }) async {
    try {
      final response = await _apiClient.dio.post('/rooms/$roomId/rounds', data: {
        if (roundNumber != null) 'roundNumber': roundNumber,
        if (placeName != null) 'placeName': placeName,
        if (memo != null) 'memo': memo,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Round.fromJson(response.data);
      } else {
        throw Exception('라운드 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('라운드 생성 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleRoomError(e);
    }
  }

  /// 참가자 추가
  Future<List<RoomParticipant>> addParticipants(int roomId, List<Map<String, dynamic>> participants) async {
    try {
      final response = await _apiClient.dio.post('/rooms/$roomId/participants', data: {
        'participants': participants,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => RoomParticipant.fromJson(json)).toList();
      } else {
        throw Exception('참가자 추가 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('참가자 추가 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleRoomError(e);
    }
  }

  /// 참가자 수정
  Future<RoomParticipant> updateParticipant(int roomId, int participantId, {
    bool? isDrinker,
    double? attendWeight,
  }) async {
    try {
      final response = await _apiClient.dio.patch('/rooms/$roomId/participants/$participantId', data: {
        if (isDrinker != null) 'isDrinker': isDrinker,
        if (attendWeight != null) 'attendWeight': attendWeight,
      });
      
      if (response.statusCode == 200) {
        return RoomParticipant.fromJson(response.data);
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
      throw _handleRoomError(e);
    }
  }

  /// 참가자 삭제
  Future<int> deleteParticipant(int roomId, int participantId) async {
    try {
      final response = await _apiClient.dio.delete('/rooms/$roomId/participants/$participantId');
      
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
      throw _handleRoomError(e);
    }
  }

  /// 에러 처리
  Exception _handleRoomError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? '방 관련 오류가 발생했습니다';
        return Exception(message);
      }
    }
    return Exception('네트워크 오류가 발생했습니다');
  }
}
