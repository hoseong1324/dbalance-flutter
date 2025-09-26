import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/sessions/repository/session_repository.dart';
import '../../features/rooms/repository/rooms_repository.dart';
import '../../features/items/repository/items_repository.dart';

// Core Providers
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final roomsRepositoryProvider = Provider<RoomsRepository>((ref) {
  return RoomsRepository();
});

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository();
});

// Session Bootstrap Provider
final sessionBootstrapProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(secureStorageProvider);
  final sessionRepo = ref.read(sessionRepositoryProvider);
  
  // Storage 초기화
  await storage.initialize();
  
  // Dio Client 초기화
  final dioClient = ref.read(dioClientProvider);
  await dioClient.initialize();
  
  // 세션 토큰 확인
  final sessionToken = await storage.getSessionToken();
  if (sessionToken == null || sessionToken.isEmpty) {
    // 디바이스 지문 생성
    final deviceInfo = DeviceInfoPlugin();
    String deviceFingerprint;
    
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceFingerprint = iosInfo.identifierForVendor ?? 'unknown';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceFingerprint = androidInfo.id;
    } else {
      deviceFingerprint = 'unknown';
    }
    
    // 게스트 세션 생성
    final sessionInfo = await sessionRepo.createGuestSession(
      deviceFingerprint: deviceFingerprint,
    );
    
    // 세션 토큰 저장
    await storage.saveSessionToken(sessionInfo.sessionToken);
    if (sessionInfo.recoveryCode != null) {
      await storage.saveRecoveryCode(sessionInfo.recoveryCode!);
    }
  }
});

// Auth State Provider
enum AuthState { guest, signedIn }

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(secureStorageProvider));
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final SecureStorage _storage;
  
  AuthStateNotifier(this._storage) : super(AuthState.guest) {
    _checkAuthState();
  }
  
  Future<void> _checkAuthState() async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      state = AuthState.signedIn;
    } else {
      state = AuthState.guest;
    }
  }
  
  void setSignedIn() {
    state = AuthState.signedIn;
  }
  
  void setGuest() {
    state = AuthState.guest;
  }
}

// Recent Rooms Provider
final roomsRecentProvider = FutureProvider<List<dynamic>>((ref) async {
  final roomsRepo = ref.read(roomsRepositoryProvider);
  return await roomsRepo.getRecentRooms();
});

// Room Detail Provider
final roomDetailProvider = FutureProvider.family<dynamic, int>((ref, roomId) async {
  final roomsRepo = ref.read(roomsRepositoryProvider);
  return await roomsRepo.getRoom(roomId);
});

// Rounds Provider
final roundsProvider = FutureProvider.family<List<dynamic>, int>((ref, roomId) async {
  final roomsRepo = ref.read(roomsRepositoryProvider);
  return await roomsRepo.getRounds(roomId);
});

// Expenses Provider
final expensesProvider = FutureProvider.family<List<dynamic>, (int, int)>((ref, params) async {
  final itemsRepo = ref.read(itemsRepositoryProvider);
  return await itemsRepo.getExpensesByRound(params.$1, params.$2);
});
