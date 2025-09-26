import '../models/auth_profile.dart';

abstract class SocialAuthService {
  Future<AuthProfile> signInWithGoogle();
  Future<AuthProfile> signInWithKakao();
  Future<AuthProfile> signInWithNaver();
  Future<void> signOutAll();
}
