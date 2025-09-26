import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 세션 부트스트랩 대기
    ref.watch(sessionBootstrapProvider).when(
      data: (_) {
        // 부트스트랩 완료 후 홈으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      },
      loading: () {},
      error: (error, stack) {
        // 오류 발생 시에도 홈으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      },
    );

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