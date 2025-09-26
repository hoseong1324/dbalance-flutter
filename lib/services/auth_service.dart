import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userDisplayName;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userDisplayName => _userDisplayName;

  // 로그인 상태 초기화
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userDisplayName = prefs.getString('userDisplayName');
    
    if (kDebugMode) {
      print('AuthService 초기화: 로그인 상태 = $_isLoggedIn, 이메일 = $_userEmail');
    }
  }

  // 로그인 처리
  Future<void> login({
    required String email,
    String? displayName,
  }) async {
    _isLoggedIn = true;
    _userEmail = email;
    _userDisplayName = displayName;

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    if (displayName != null) {
      await prefs.setString('userDisplayName', displayName);
    }

    if (kDebugMode) {
      print('로그인 완료: $email');
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userDisplayName = null;

    // SharedPreferences에서 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
    await prefs.remove('userDisplayName');

    if (kDebugMode) {
      print('로그아웃 완료');
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserInfo({
    String? email,
    String? displayName,
  }) async {
    if (email != null) _userEmail = email;
    if (displayName != null) _userDisplayName = displayName;

    final prefs = await SharedPreferences.getInstance();
    if (email != null) await prefs.setString('userEmail', email);
    if (displayName != null) await prefs.setString('userDisplayName', displayName);
  }
}
