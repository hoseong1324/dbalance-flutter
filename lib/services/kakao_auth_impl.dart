import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../models/auth_profile.dart';

Future<AuthProfile> signInWithKakaoImpl() async {
  try {
    // 카카오 SDK 초기화
    kakao.KakaoSdk.init(nativeAppKey: '21ececcc9510348d55784751f9f01a67');
    print('✅ 카카오 SDK 초기화 완료');
    
    kakao.OAuthToken token;
    if (await kakao.isKakaoTalkInstalled()) {
      print('🔍 카카오톡 앱 로그인 시도...');
      token = await kakao.UserApi.instance.loginWithKakaoTalk();
    } else {
      print('🔍 카카오 웹 로그인 시도...');
      token = await kakao.UserApi.instance.loginWithKakaoAccount(); // 웹 로그인 폴백
    }
    final user = await kakao.UserApi.instance.me();
    return AuthProfile(
      provider: 'kakao',
      id: user.id.toString(),
      email: user.kakaoAccount?.email,
      name: user.kakaoAccount?.profile?.nickname,
      avatarUrl: user.kakaoAccount?.profile?.thumbnailImageUrl,
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
  } catch (e) {
    print('❌ 카카오 로그인 실패: $e');
    // 토크 실패 → 계정 로그인 폴백 마지막 시도
    try {
      print('🔄 카카오 계정 로그인 폴백 시도...');
      final token = await kakao.UserApi.instance.loginWithKakaoAccount();
      final user = await kakao.UserApi.instance.me();
      return AuthProfile(
        provider: 'kakao',
        id: user.id.toString(),
        email: user.kakaoAccount?.email,
        name: user.kakaoAccount?.profile?.nickname,
        avatarUrl: user.kakaoAccount?.profile?.thumbnailImageUrl,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      );
    } catch (e2) {
      print('❌ 카카오 로그인 최종 실패: $e2');
      rethrow;
    }
  }
}
