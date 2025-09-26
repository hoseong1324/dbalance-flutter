import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/social_auth_service_impl.dart';
import '../models/auth_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SocialAuthServiceImpl _socialAuthService = SocialAuthServiceImpl();
  bool _isLoading = false;
  String? _currentProvider;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('이메일과 비밀번호를 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await AuthService().login(
        email: _emailController.text,
        displayName: _emailController.text.split('@')[0],
      );
      _showSnackBar('로그인 성공!');
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showSnackBar('로그인 실패: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSocialLogin(Future<AuthProfile> Function() socialLoginFn, String provider) async {
    setState(() {
      _isLoading = true;
      _currentProvider = provider;
    });

    try {
      final AuthProfile profile = await socialLoginFn();
      await ApiService().socialLogin(
        provider: profile.provider,
        idToken: profile.provider == 'google' ? profile.refreshToken : null,
        accessToken: profile.accessToken,
      );
      await AuthService().login(
        email: profile.email ?? '',
        displayName: profile.name ?? profile.email,
      );
      _showSnackBar('${profile.provider} 로그인 성공!');
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      print('❌ $provider 로그인 실패: $e');
      _showErrorDialog('$provider 로그인 실패', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
        _currentProvider = null;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 다시 시도 로직
              if (_currentProvider != null) {
                switch (_currentProvider) {
                  case 'google':
                    _handleSocialLogin(_socialAuthService.signInWithGoogle, 'google');
                    break;
                  case 'kakao':
                    _handleSocialLogin(_socialAuthService.signInWithKakao, 'kakao');
                    break;
                  case 'naver':
                    _handleSocialLogin(_socialAuthService.signInWithNaver, 'naver');
                    break;
                }
              }
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _currentProvider != null 
                        ? '$_currentProvider 로그인 중...' 
                        : '로그인 중...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.balance,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text('로그인', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pushNamed('/signup');
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 16, color: Color(0xFF4ECDC4)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '또는',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 소셜 로그인 버튼들 (가이드 요구사항: 버튼 3개)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _handleSocialLogin(_socialAuthService.signInWithGoogle, 'google'),
                          icon: SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 20,
                            height: 20,
                          ),
                          label: const Text('Google', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade500,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _handleSocialLogin(_socialAuthService.signInWithKakao, 'kakao'),
                          icon: SvgPicture.asset(
                            'assets/icons/kakao.svg',
                            width: 20,
                            height: 20,
                          ),
                          label: const Text('Kakao', style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _handleSocialLogin(_socialAuthService.signInWithNaver, 'naver'),
                      icon: SvgPicture.asset(
                        'assets/icons/naver.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: const Text('Naver', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: const Text(
                      '게스트로 계속하기',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}