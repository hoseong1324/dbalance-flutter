import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../models/auth_profile.dart';

Future<AuthProfile> signInWithNaverImpl() async {
  try {
    print('🔍 네이버 로그인 시도...');
    // flutter_naver_login 2.1.1 API 사용
    final result = await FlutterNaverLogin.logIn();
    
    print('🔍 네이버 로그인 결과: ${result.status}');
    
    // flutter_naver_login 2.1.1에서는 account와 accessToken이 null이 아닌지로 성공 여부 확인
    if (result.account != null && result.accessToken != null) {
      final account = result.account!;
      final token = result.accessToken!;
      
      print('✅ 네이버 로그인 성공: ${account.email}');
      
      return AuthProfile(
        provider: 'naver',
        id: account.id ?? '',
        email: account.email,
        name: account.name,
        avatarUrl: account.profileImage,
        accessToken: token.accessToken ?? '',
        refreshToken: token.refreshToken,
      );
    } else {
      print('❌ 네이버 로그인 실패: ${result.errorMessage}');
      throw Exception('Naver login failed: ${result.errorMessage ?? 'Unknown error'}');
    }
  } catch (e) {
    print('❌ 네이버 로그인 예외: $e');
    rethrow;
  }
}
