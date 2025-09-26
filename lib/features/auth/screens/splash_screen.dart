import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_providers.dart';
import '../providers/auth_provider.dart';
import '../../sessions/providers/session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Storage 초기화
      await ref.read(storageServiceProvider).initialize();
      
      // API Client 초기화
      ref.read(apiClientProvider);
      
      // 세션 토큰 확인 및 게스트 세션 생성
      final sessionToken = await ref.read(storageServiceProvider).getSessionToken();
      if (sessionToken == null || sessionToken.isEmpty) {
        await ref.read(sessionProvider.notifier).createGuestSession();
        // 게스트 세션 생성 후 게스트 상태로 설정
        ref.read(authStateProvider.notifier).setGuest();
      } else {
        // 인증 상태 초기화 (기존 토큰 확인)
        await ref.read(authStateProvider.notifier).initialize();
      }
      
      // 잠시 대기 (스플래시 효과)
      await Future.delayed(const Duration(seconds: 1));
      
      // 홈으로 이동
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      print('❌ 초기화 오류: $e');
      
      if (mounted) {
        // 오류 발생 시에도 홈으로 이동 시도
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4ECDC4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.balance,
                size: 60,
                color: Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(height: 32),
            
            // 앱 이름
            const Text(
              'D-Balance',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // 부제목
            const Text(
              '확실한 정산을 경험해보세요!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            
            // 로딩 인디케이터
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
