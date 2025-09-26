import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      
      final response = await authRepo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 응답 데이터 처리
      Map<String, dynamic> authData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        authData = response['data'];
      } else {
        authData = response;
      }

      // 토큰 저장
      await storage.saveTokens(
        authData['accessToken'],
        authData['refreshToken'],
      );

      // 사용자 정보 저장
      if (authData['user'] != null) {
        await storage.saveUser(User.fromJson(authData['user']));
      }

      // 인증 상태 업데이트
      ref.read(authStateProvider.notifier).setSignedIn();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
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

  Future<void> _socialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      
      String? idToken;
      String? accessToken;
      String? device;
      String? nonce;

      switch (provider) {
        case 'google':
          final result = await _signInWithGoogle();
          idToken = result['idToken'];
          accessToken = result['accessToken'];
          break;
        case 'apple':
          final result = await _signInWithApple();
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

      device = Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android';

      final response = await authRepo.socialLogin(
        provider: provider,
        idToken: idToken,
        accessToken: accessToken,
        device: device,
        nonce: nonce,
      );

      // 응답 데이터 처리
      Map<String, dynamic> authData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        authData = response['data'];
      } else {
        authData = response;
      }

      // 토큰 저장
      await storage.saveTokens(
        authData['accessToken'],
        authData['refreshToken'],
      );

      // 사용자 정보 저장
      if (authData['user'] != null) {
        await storage.saveUser(User.fromJson(authData['user']));
      }

      // 인증 상태 업데이트
      ref.read(authStateProvider.notifier).setSignedIn();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${provider} 로그인 실패: $e')),
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
    final result = await FlutterNaverLogin.logIn();
    if (result.status == NaverLoginStatus.loggedIn) {
      return result.accessToken?.accessToken;
    } else {
      throw Exception('Naver 로그인에 실패했습니다.');
    }
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.balance,
                      size: 40,
                      color: Color(0xFF4ECDC4),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 제목
                const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // 부제목
                Text(
                  'D-Balance에 오신 것을 환영합니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // 로그인 버튼
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
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
                        : const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 회원가입 링크
                TextButton(
                  onPressed: () {
                    context.push('/auth/signup');
                  },
                  child: const Text(
                    '계정이 없으신가요? 회원가입',
                    style: TextStyle(color: Color(0xFF4ECDC4)),
                  ),
                ),
                const SizedBox(height: 32),
                
                // 구분선
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 32),
                
                // 소셜 로그인 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(Icons.g_mobiledata, 'Google', () {
                      _socialLogin('google');
                    }),
                    const SizedBox(width: 8),
                    _buildSocialButton(Icons.apple, 'Apple', () {
                      _socialLogin('apple');
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(Icons.chat_bubble_outline, 'Kakao', () {
                      _socialLogin('kakao');
                    }),
                    const SizedBox(width: 8),
                    _buildSocialButton(Icons.search, 'Naver', () {
                      _socialLogin('naver');
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}