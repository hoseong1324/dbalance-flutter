import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _sessionToken;
  String? _accessToken;

  void initialize() {
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
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // X-Session-Token 헤더 추가
        if (_sessionToken != null && _sessionToken!.isNotEmpty) {
          options.headers['X-Session-Token'] = _sessionToken!;
        }

        // Authorization 헤더 추가 (로그인된 경우)
        if (_accessToken != null && _accessToken!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }

        if (kDebugMode) {
          debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Data: ${options.data}');
          }
        }

        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          debugPrint('Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          debugPrint('Message: ${error.message}');
          if (error.response?.data != null) {
            debugPrint('Error Data: ${error.response?.data}');
          }
        }
        handler.next(error);
      },
    ));
  }

  void setSessionToken(String? token) {
    _sessionToken = token;
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void clearTokens() {
    _sessionToken = null;
    _accessToken = null;
  }

  // 게스트 세션 생성
  Future<Map<String, dynamic>> createGuestSession({String? deviceFingerprint}) async {
    try {
      final response = await _dio.post('/sessions/guest', data: {
        if (deviceFingerprint != null) 'deviceFingerprint': deviceFingerprint,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final sessionData = data['data'];
          if (sessionData['sessionToken'] != null) {
            setSessionToken(sessionData['sessionToken']);
          }
          return sessionData;
        }
        return data;
      } else {
        throw Exception('게스트 세션 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('게스트 세션 생성 오류: ${e.message}');
    }
  }

  // 하트비트
  Future<void> heartbeat() async {
    try {
      await _dio.patch('/sessions/heartbeat');
    } on DioException catch (e) {
      throw Exception('하트비트 오류: ${e.message}');
    }
  }

  // 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final authData = data['data'];
          if (authData['accessToken'] != null) {
            setAccessToken(authData['accessToken']);
          }
          return authData;
        }
        return data;
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('로그인 오류: ${e.message}');
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? nickname,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
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
      throw Exception('회원가입 오류: ${e.message}');
    }
  }

  // 소셜 로그인
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? device,
    String? nonce,
  }) async {
    try {
      final response = await _dio.post('/auth/social-login', data: {
        'provider': provider,
        if (idToken != null) 'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        if (device != null) 'device': device,
        if (nonce != null) 'nonce': nonce,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final authData = data['data'];
          if (authData['accessToken'] != null) {
            setAccessToken(authData['accessToken']);
          }
          
          // 사용자 정보가 있으면 AuthService에 저장
          if (authData['user'] != null) {
            final user = authData['user'];
            await AuthService().login(
              email: user['email'] ?? '',
              displayName: user['displayName'] ?? user['nickname'],
            );
          }
          
          return authData;
        }
        return data;
      } else {
        throw Exception('소셜 로그인 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('소셜 로그인 오류: ${e.message}');
    }
  }

  // 최근 방 목록 조회
  Future<List<Map<String, dynamic>>> getRecentRooms() async {
    try {
      final response = await _dio.get('/rooms/recent');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 응답 데이터가 null이거나 예상과 다른 경우 빈 배열 반환
        if (data == null) {
          return [];
        }
        
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final roomsData = data['data'];
          if (roomsData is List) {
            return List<Map<String, dynamic>>.from(roomsData);
          }
          return [];
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        
        // 예상과 다른 데이터 형태인 경우 빈 배열 반환
        return [];
      } else {
        throw Exception('방 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // 네트워크 오류나 서버 오류인 경우에만 예외 발생
      if (e.response?.statusCode != null && e.response!.statusCode! >= 400) {
        throw Exception('방 목록 조회 오류: ${e.message}');
      } else {
        // 네트워크 오류 등은 빈 배열 반환
        return [];
      }
    } catch (e) {
      // 기타 예외는 빈 배열 반환
      return [];
    }
  }

  // 방 생성
  Future<Map<String, dynamic>> createRoom({
    required String name,
    String? date,
    String? inviteCode,
  }) async {
    try {
      final response = await _dio.post('/rooms', data: {
        'name': name,
        if (date != null) 'date': date,
        if (inviteCode != null) 'inviteCode': inviteCode,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data'];
        }
        return data;
      } else {
        throw Exception('방 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('방 생성 오류: ${e.message}');
    }
  }

  // 방 조회
  Future<Map<String, dynamic>> getRoom(int roomId) async {
    try {
      final response = await _dio.get('/rooms/$roomId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data'];
        }
        return data;
      } else {
        throw Exception('방 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('방 조회 오류: ${e.message}');
    }
  }

  // 라운드 목록 조회
  Future<List<Map<String, dynamic>>> getRounds(int roomId) async {
    try {
      final response = await _dio.get('/rooms/$roomId/rounds');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception('라운드 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('라운드 목록 조회 오류: ${e.message}');
    }
  }

  // 라운드 생성
  Future<Map<String, dynamic>> createRound(int roomId, {
    int? roundNumber,
    String? placeName,
    String? memo,
  }) async {
    try {
      final response = await _dio.post('/rooms/$roomId/rounds', data: {
        if (roundNumber != null) 'roundNumber': roundNumber,
        if (placeName != null) 'placeName': placeName,
        if (memo != null) 'memo': memo,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data'];
        }
        return data;
      } else {
        throw Exception('라운드 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('라운드 생성 오류: ${e.message}');
    }
  }

  // 참가자 추가
  Future<List<Map<String, dynamic>>> addParticipants(int roomId, List<Map<String, dynamic>> participants) async {
    try {
      final response = await _dio.post('/rooms/$roomId/participants', data: {
        'participants': participants,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception('참가자 추가 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('참가자 추가 오류: ${e.message}');
    }
  }

  // 지출 생성
  Future<Map<String, dynamic>> createExpense({
    required int roomId,
    required int roundId,
    required int payerParticipantId,
    required double totalAmount,
    String? currency,
    String? memo,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _dio.post('/items/expenses', data: {
        'roomId': roomId,
        'roundId': roundId,
        'payerParticipantId': payerParticipantId,
        'totalAmount': totalAmount,
        if (currency != null) 'currency': currency,
        if (memo != null) 'memo': memo,
        'items': items,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data'];
        }
        return data;
      } else {
        throw Exception('지출 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('지출 생성 오류: ${e.message}');
    }
  }

  // 라운드별 지출 목록 조회
  Future<List<Map<String, dynamic>>> getExpensesByRound(int roomId, int roundId) async {
    try {
      final response = await _dio.get('/items/rooms/$roomId/rounds/$roundId/expenses');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception('지출 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('지출 목록 조회 오류: ${e.message}');
    }
  }
}
