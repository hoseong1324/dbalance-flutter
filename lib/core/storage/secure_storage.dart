import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Session Token
  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: 'session_token', value: token);
  }

  Future<String?> getSessionToken() async {
    return await _storage.read(key: 'session_token');
  }

  Future<void> deleteSessionToken() async {
    await _storage.delete(key: 'session_token');
  }

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // Recovery Code
  Future<void> saveRecoveryCode(String code) async {
    await _storage.write(key: 'recovery_code', value: code);
  }

  Future<String?> getRecoveryCode() async {
    return await _storage.read(key: 'recovery_code');
  }

  Future<void> deleteRecoveryCode() async {
    await _storage.delete(key: 'recovery_code');
  }

  // User
  Future<void> saveUser(User user) async {
    await _storage.write(key: 'user', value: user.toJson().toString());
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      try {
        // JSON 파싱 로직 (간단한 구현)
        return null; // TODO: JSON 파싱 구현
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: 'user');
  }

  // Tokens 함께 저장
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  // 모든 토큰 삭제
  Future<void> clearAllTokens() async {
    await _storage.deleteAll();
  }

  // SharedPreferences (가벼운 UI 상태)
  Future<bool> isFirstLaunch() async {
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool('is_first_launch', isFirst);
  }

  Future<String?> getTheme() async {
    return _prefs?.getString('theme');
  }

  Future<void> setTheme(String theme) async {
    await _prefs?.setString('theme', theme);
  }

  Future<List<String>> getRecentRooms() async {
    return _prefs?.getStringList('recent_rooms') ?? [];
  }

  Future<void> addRecentRoom(String roomId) async {
    final rooms = await getRecentRooms();
    rooms.remove(roomId);
    rooms.insert(0, roomId);
    if (rooms.length > 10) {
      rooms.removeLast();
    }
    await _prefs?.setStringList('recent_rooms', rooms);
  }

  Future<void> removeRecentRoom(String roomId) async {
    final rooms = await getRecentRooms();
    rooms.remove(roomId);
    await _prefs?.setStringList('recent_rooms', rooms);
  }
}
