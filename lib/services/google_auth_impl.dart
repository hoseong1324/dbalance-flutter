import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_profile.dart';

final _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // iOS에서 필요시 clientId 추가 가능
);

Future<AuthProfile> signInWithGoogleImpl() async {
  try {
    print('🔍 구글 로그인 시도...');
    final acc = await _googleSignIn.signIn();
    if (acc == null) {
      print('❌ 구글 로그인 취소됨');
      throw Exception('Google sign-in cancelled');
    }
    
    print('🔍 구글 인증 토큰 가져오기...');
    final auth = await acc.authentication;
    
    print('✅ 구글 로그인 성공: ${acc.email}');
    
    return AuthProfile(
      provider: 'google',
      id: acc.id,
      email: acc.email,
      name: acc.displayName,
      avatarUrl: acc.photoUrl,
      accessToken: auth.accessToken ?? '',
      refreshToken: auth.idToken, // 서버 교환 시 webClientId 사용
    );
  } catch (e) {
    print('❌ 구글 로그인 실패: $e');
    rethrow;
  }
}
