class AppConfig {
  static const String baseUrl = 'http://211.56.253.181:3000';
  static const String apiVersion = 'v1';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Session
  static const Duration sessionHeartbeatInterval = Duration(minutes: 5);
  
  // Locale
  static const String defaultLocale = 'ko_KR';
  static const String defaultTimezone = 'Asia/Seoul';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String sessionTokenKey = 'session_token';
  static const String userKey = 'user';
  
  // Social Login (기존 설정 유지)
  static const String googleClientIdAndroid = '1052447286041-1rjieb0t4ckp4k60n50v2luogvcl9gr2.apps.googleusercontent.com';
  static const String googleClientIdIOS = '1052447286041-iaq8igbcrrhmvsdhc5v5ccd1b5j7n06b.apps.googleusercontent.com';
  static const String kakaoNativeAppKey = '21ececcc9510348d55784751f9f01a67';
  static const String naverClientId = 'hQfS5ST__8Q7Mm8g26Cw';
  static const String naverClientSecret = 'kRfF_spWVG';
}
