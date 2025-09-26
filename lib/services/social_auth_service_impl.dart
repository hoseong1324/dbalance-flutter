import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_profile.dart';
import 'social_auth_service.dart';
import 'kakao_auth_impl.dart';
import 'naver_auth_impl.dart';
import 'google_auth_impl.dart';

class SocialAuthServiceImpl implements SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  Future<AuthProfile> signInWithGoogle() => signInWithGoogleImpl();

  @override
  Future<AuthProfile> signInWithKakao() => signInWithKakaoImpl();

  @override
  Future<AuthProfile> signInWithNaver() => signInWithNaverImpl();

  @override
  Future<void> signOutAll() async {
    try { await _googleSignIn.signOut(); } catch (_) {}
    try { await kakao.UserApi.instance.logout(); } catch (_) {}
    try { await FlutterNaverLogin.logOut(); } catch (_) {}
  }
}
