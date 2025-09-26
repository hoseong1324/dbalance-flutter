import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../../shared/models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage (토큰, 사용자 정보)
  
  /// Access Token 저장/조회/삭제
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
  }

  /// Refresh Token 저장/조회/삭제
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
  }

  /// Session Token 저장/조회/삭제
  Future<void> saveSessionToken(String token) async {
    await _secureStorage.write(key: AppConfig.sessionTokenKey, value: token);
  }

  Future<String?> getSessionToken() async {
    return await _secureStorage.read(key: AppConfig.sessionTokenKey);
  }

  Future<void> deleteSessionToken() async {
    await _secureStorage.delete(key: AppConfig.sessionTokenKey);
  }

  /// User 정보 저장/조회/삭제
  Future<void> saveUser(User user) async {
    await _secureStorage.write(key: AppConfig.userKey, value: user.toJson().toString());
  }

  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: AppConfig.userKey);
    if (userJson != null) {
      // JSON 파싱 로직 (간단한 구현)
      try {
        // 실제로는 JSON 파싱이 필요하지만, 여기서는 간단히 처리
        return null; // TODO: JSON 파싱 구현
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  /// 모든 토큰 삭제 (로그아웃)
  Future<void> clearAllTokens() async {
    await _secureStorage.deleteAll();
  }

  // SharedPreferences (가벼운 UI 상태)
  
  /// 앱 시작 여부
  Future<bool> isFirstLaunch() async {
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool('is_first_launch', isFirst);
  }

  /// 테마 설정
  Future<String?> getTheme() async {
    return _prefs?.getString('theme');
  }

  Future<void> setTheme(String theme) async {
    await _prefs?.setString('theme', theme);
  }

  /// 언어 설정
  Future<String?> getLanguage() async {
    return _prefs?.getString('language');
  }

  Future<void> setLanguage(String language) async {
    await _prefs?.setString('language', language);
  }

  /// 최근 방 목록
  Future<List<String>> getRecentRooms() async {
    return _prefs?.getStringList('recent_rooms') ?? [];
  }

  Future<void> addRecentRoom(String roomId) async {
    final rooms = await getRecentRooms();
    rooms.remove(roomId); // 중복 제거
    rooms.insert(0, roomId); // 맨 앞에 추가
    if (rooms.length > 10) {
      rooms.removeLast(); // 최대 10개만 유지
    }
    await _prefs?.setStringList('recent_rooms', rooms);
  }

  Future<void> removeRecentRoom(String roomId) async {
    final rooms = await getRecentRooms();
    rooms.remove(roomId);
    await _prefs?.setStringList('recent_rooms', rooms);
  }
}
