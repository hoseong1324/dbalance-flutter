import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/providers/repository_providers.dart';

/// 인증 상태
enum AuthState {
  initial,    // 초기 상태
  loading,    // 로딩 중
  guest,      // 게스트 세션
  signedIn,   // 로그인됨
  signedOut,  // 로그아웃됨
  error,      // 오류
}

/// 인증 상태 관리
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._storageService) : super(AuthState.initial);

  final StorageService _storageService;

  /// 초기화
  Future<void> initialize() async {
    state = AuthState.loading;
    
    try {
      final accessToken = await _storageService.getAccessToken();
      final sessionToken = await _storageService.getSessionToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        state = AuthState.signedIn;
      } else if (sessionToken != null && sessionToken.isNotEmpty) {
        state = AuthState.guest;
      } else {
        state = AuthState.signedOut;
      }
    } catch (e) {
      state = AuthState.error;
    }
  }

  /// 로그인 성공
  void setSignedIn() {
    state = AuthState.signedIn;
  }

  /// 게스트 세션 설정
  void setGuest() {
    state = AuthState.guest;
  }

  /// 로그아웃
  void setSignedOut() {
    state = AuthState.signedOut;
  }

  /// 오류 설정
  void setError() {
    state = AuthState.error;
  }

  /// 로딩 설정
  void setLoading() {
    state = AuthState.loading;
  }
}

/// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(storageServiceProvider));
});

/// 현재 사용자 Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getUser();
});

/// 로그인 여부 Provider
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState == AuthState.signedIn;
});

/// 게스트 여부 Provider
final isGuestProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState == AuthState.guest;
});

/// 로딩 여부 Provider
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState == AuthState.loading;
});
