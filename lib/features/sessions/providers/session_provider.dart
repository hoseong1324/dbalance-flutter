import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../core/providers/repository_providers.dart';
import '../dto/session_dto.dart';
import '../repository/session_repository.dart';
import '../../../core/storage/storage_service.dart';

/// 세션 상태 관리
class SessionNotifier extends StateNotifier<AsyncValue<String?>> {
  SessionNotifier(this._sessionRepository, this._storageService) : super(const AsyncValue.data(null));

  final SessionRepository _sessionRepository;
  final StorageService _storageService;

  /// 게스트 세션 생성
  Future<void> createGuestSession() async {
    state = const AsyncValue.loading();
    
    try {
      // 디바이스 지문 생성
      final deviceInfo = DeviceInfoPlugin();
      String? deviceFingerprint;
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceFingerprint = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceFingerprint = iosInfo.identifierForVendor;
      }

      final request = CreateGuestSessionRequest(
        deviceFingerprint: deviceFingerprint,
      );

      final response = await _sessionRepository.createGuestSession(request);
      
      // 세션 토큰 저장
      await _storageService.saveSessionToken(response.sessionToken);
      
      state = AsyncValue.data(response.sessionToken);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 하트비트 전송
  Future<void> sendHeartbeat() async {
    try {
      await _sessionRepository.heartbeat();
    } catch (e) {
      if (kDebugMode) {
        print('하트비트 실패: $e');
      }
    }
  }

  /// 세션 토큰 조회
  Future<String?> getSessionToken() async {
    return await _storageService.getSessionToken();
  }

  /// 세션 토큰 삭제
  Future<void> clearSessionToken() async {
    await _storageService.deleteSessionToken();
    state = const AsyncValue.data(null);
  }
}

/// Session Provider
final sessionProvider = StateNotifierProvider<SessionNotifier, AsyncValue<String?>>((ref) {
  return SessionNotifier(
    ref.read(sessionRepositoryProvider),
    ref.read(storageServiceProvider),
  );
});

/// 현재 세션 토큰 Provider
final currentSessionTokenProvider = FutureProvider<String?>((ref) async {
  final sessionNotifier = ref.read(sessionProvider.notifier);
  return await sessionNotifier.getSessionToken();
});
