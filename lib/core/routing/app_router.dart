import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/rooms/screens/home_screen.dart';
import '../../features/rooms/screens/room_detail_screen.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 인증 화면들
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 메인 화면들
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/rooms/:roomId',
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
    ],
    
    // 리다이렉트 로직
    redirect: (context, state) {
      final currentLocation = state.fullPath ?? '/';
      final authState = ref.read(authStateProvider);
      
      // 스플래시 화면에서는 리다이렉트하지 않음
      if (currentLocation == '/') {
        return null;
      }
      
      // 로그인되지 않은 상태에서 보호된 경로 접근 시 로그인 화면으로
      if (authState == AuthState.guest && 
          !currentLocation.startsWith('/auth/')) {
        return '/auth/login';
      }
      
      // 로그인된 상태에서 로그인 화면 접근 시 홈으로
      if (authState == AuthState.signedIn && 
          currentLocation.startsWith('/auth/')) {
        return '/home';
      }
      
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