import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/auth_profile.dart';

Future<AuthProfile> signInWithAppleImpl() async {
  try {
    print('🔍 Apple 로그인 시도...');
    
    // Apple 로그인 시도
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (credential.identityToken == null) {
      throw Exception('Apple ID 토큰을 가져올 수 없습니다');
    }

    print('✅ Apple 로그인 성공: ${credential.userIdentifier}');

    return AuthProfile(
      provider: 'apple',
      id: credential.userIdentifier ?? '',
      email: credential.email ?? credential.userIdentifier ?? '',
      name: credential.givenName != null && credential.familyName != null
          ? '${credential.givenName} ${credential.familyName}'
          : credential.email ?? credential.userIdentifier,
      avatarUrl: null, // Apple은 프로필 이미지를 제공하지 않음
      accessToken: credential.authorizationCode ?? '',
      refreshToken: credential.identityToken,
    );
  } catch (e) {
    print('❌ Apple 로그인 실패: $e');
    rethrow;
  }
}
