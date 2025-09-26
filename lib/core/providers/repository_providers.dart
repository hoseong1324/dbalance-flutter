import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/sessions/repository/session_repository.dart';
import '../../features/rooms/repository/rooms_repository.dart';
import '../../features/participants/repository/participants_repository.dart';
import '../../features/items/repository/items_repository.dart';

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  client.initialize();
  return client;
});

/// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Session Repository Provider
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

/// Rooms Repository Provider
final roomsRepositoryProvider = Provider<RoomsRepository>((ref) {
  return RoomsRepository();
});

/// Participants Repository Provider
final participantsRepositoryProvider = Provider<ParticipantsRepository>((ref) {
  return ParticipantsRepository();
});

/// Items Repository Provider
final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository();
});
