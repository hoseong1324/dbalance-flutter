import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/repository_providers.dart';
import '../providers/auth_provider.dart';
import '../dto/auth_dto.dart';

class SocialLoginScreen extends ConsumerStatefulWidget {
  final String provider;
  
  const SocialLoginScreen({
    super.key,
    required this.provider,
  });

  @override
  ConsumerState<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends ConsumerState<SocialLoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${_getProviderName(widget.provider)} 로그인',
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  _getProviderIcon(widget.provider),
                  size: 60,
                  color: _getProviderColor(widget.provider),
                ),
              ),
              const SizedBox(height: 32),
              
              // 제목
              Text(
                '${_getProviderName(widget.provider)}로 로그인',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              
              // 설명
              Text(
                '${_getProviderName(widget.provider)} 계정으로\nD-Balance에 로그인하세요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSocialLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getProviderColor(widget.provider),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '${_getProviderName(widget.provider)}로 계속하기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 취소 버튼
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  '다른 방법으로 로그인',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProviderName(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'kakao':
        return 'Kakao';
      case 'naver':
        return 'Naver';
      default:
        return 'Unknown';
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'kakao':
        return Icons.chat_bubble_outline;
      case 'naver':
        return Icons.search;
      default:
        return Icons.login;
    }
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return const Color(0xFF4285F4);
      case 'apple':
        return const Color(0xFF000000);
      case 'kakao':
        return const Color(0xFFFEE500);
      case 'naver':
        return const Color(0xFF03C75A);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  Future<void> _handleSocialLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? accessToken;
      String? idToken;
      String? nonce;

      switch (widget.provider.toLowerCase()) {
        case 'google':
          final result = await _signInWithGoogle();
          accessToken = result['accessToken'];
          idToken = result['idToken'];
          break;
        case 'apple':
          final result = await _signInWithApple();
          accessToken = result['accessToken'];
          idToken = result['idToken'];
          nonce = result['nonce'];
          break;
        case 'kakao':
          accessToken = await _signInWithKakao();
          break;
        case 'naver':
          accessToken = await _signInWithNaver();
          break;
      }

      if (accessToken == null && idToken == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      // 서버에 소셜 로그인 요청
      final request = SocialLoginRequest(
        provider: widget.provider,
        idToken: idToken,
        accessToken: accessToken,
        device: Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android',
        nonce: nonce,
      );

      final response = await ref.read(authRepositoryProvider).socialLogin(request);
      
      // 토큰 저장
      await ref.read(storageServiceProvider).saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await ref.read(storageServiceProvider).saveUser(response.user);
      
      // 인증 상태 업데이트
      ref.read(authStateProvider.notifier).setSignedIn();
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_getProviderName(widget.provider)} 로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, String?>> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Theme.of(context).platform == TargetPlatform.iOS
          ? '1052447286041-iaq8igbcrrhmvsdhc5v5ccd1b5j7n06b.apps.googleusercontent.com'
          : null,
    );

    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google 로그인이 취소되었습니다.');
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    return {
      'accessToken': auth.accessToken,
      'idToken': auth.idToken,
    };
  }

  Future<Map<String, String?>> _signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: 'nonce_${DateTime.now().millisecondsSinceEpoch}',
    );

    return {
      'accessToken': credential.identityToken,
      'idToken': credential.identityToken,
      'nonce': 'nonce_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  Future<String?> _signInWithKakao() async {
    // Kakao SDK 초기화
    kakao.KakaoSdk.init(
      nativeAppKey: '21ececcc9510348d55784751f9f01a67',
    );

    // 카카오톡 설치 여부 확인
    if (await kakao.isKakaoTalkInstalled()) {
      try {
        final kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoTalk();
        return token.accessToken;
      } catch (e) {
        // 카카오톡 로그인 실패 시 카카오계정으로 로그인
        try {
          final kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
          return token.accessToken;
        } catch (e2) {
          throw Exception('Kakao 로그인에 실패했습니다: $e2');
        }
      }
    } else {
      // 카카오톡이 설치되지 않은 경우 카카오계정으로 로그인
      try {
        final kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
        return token.accessToken;
      } catch (e) {
        throw Exception('Kakao 로그인에 실패했습니다: $e');
      }
    }
  }

  Future<String?> _signInWithNaver() async {
    // 네이버 로그인 URL 생성
    final clientId = 'hQfS5ST__8Q7Mm8g26Cw';
    final redirectUri = 'dbalance-hQfS5ST--8Q7Mm8g26Cw://oauth';
    final state = 'RANDOM_STATE_${DateTime.now().millisecondsSinceEpoch}';
    
    final loginUrl = 'https://nid.naver.com/oauth2.0/authorize?'
        'response_type=code&'
        'client_id=$clientId&'
        'redirect_uri=${Uri.encodeComponent(redirectUri)}&'
        'state=$state';

    // 네이버 앱으로 로그인 시도
    try {
      final uri = Uri.parse(loginUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // 실제 구현에서는 URL 스킴 콜백을 통해 인증 코드를 받아야 합니다
        // 여기서는 임시로 더미 토큰을 반환합니다
        await Future.delayed(const Duration(seconds: 2));
        return 'naver_access_token_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        throw Exception('네이버 앱을 열 수 없습니다.');
      }
    } catch (e) {
      throw Exception('네이버 로그인에 실패했습니다: $e');
    }
  }
}
