import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/social_login_screen.dart';
import '../../features/rooms/screens/home_screen.dart';
import '../../features/rooms/screens/room_detail_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 인증 화면들
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      
      // 메인 화면들
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/room/:roomId',
        builder: (context, state) {
          final roomId = int.tryParse(state.pathParameters['roomId'] ?? '');
          if (roomId == null) {
            return const Scaffold(
              body: Center(
                child: Text('잘못된 방 ID입니다'),
              ),
            );
          }
          return RoomDetailScreen(roomId: roomId);
        },
      ),
      
      // 소셜 로그인 화면
      GoRoute(
        path: '/social-login',
        builder: (context, state) {
          final provider = state.uri.queryParameters['provider'] ?? 'google';
          return SocialLoginScreen(provider: provider);
        },
      ),
    ],
    
    // 리다이렉트 로직
    redirect: (context, state) {
      final currentLocation = state.fullPath ?? '/';
      final authState = ref.read(authStateProvider);
      
      print('🔄 라우터 리다이렉트 체크: $currentLocation, AuthState: $authState');
      
      // 스플래시 화면에서는 리다이렉트하지 않음
      if (currentLocation == '/splash') {
        print('✅ 스플래시 화면 - 리다이렉트 없음');
        return null;
      }
      
      // 로그인되지 않은 상태(게스트도 아닌 상태)에서 보호된 경로 접근 시 로그인 화면으로
      if (authState == AuthState.signedOut && 
          !currentLocation.startsWith('/login') && 
          !currentLocation.startsWith('/signup') &&
          !currentLocation.startsWith('/social-login')) {
        print('🔒 로그인 필요 - 로그인 화면으로 리다이렉트');
        return '/login';
      }
      
      // 로그인된 상태 또는 게스트 상태에서 로그인/회원가입 화면 접근 시 홈으로
      if ((authState == AuthState.signedIn || authState == AuthState.guest) && 
          (currentLocation.startsWith('/login') || 
           currentLocation.startsWith('/signup'))) {
        print('🏠 이미 인증됨 - 홈으로 리다이렉트');
        return '/home';
      }
      
      print('✅ 리다이렉트 없음 - 정상 진행');
      return null;
    },
    
    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              '페이지를 찾을 수 없습니다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '요청하신 페이지가 존재하지 않습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
              ),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    ),
  );
});
