import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/models/room.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _roomNameController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 입력해주세요')),
      );
      return;
    }

    try {
      final roomsRepo = ref.read(roomsRepositoryProvider);
      final room = await roomsRepo.createRoom(
        name: _roomNameController.text.trim(),
      );

      if (mounted) {
        context.push('/rooms/${room.id}');
        _roomNameController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 생성 실패: $e')),
        );
      }
    }
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 방 만들기'),
        content: TextField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            labelText: '방 이름',
            hintText: '예: 회식비 정산',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              _roomNameController.clear();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _createRoom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
            ),
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.clearAllTokens();
      ref.read(authStateProvider.notifier).setGuest();
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final roomsAsync = ref.watch(roomsRecentProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'D-Balance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        actions: [
          if (authState == AuthState.guest)
            TextButton(
              onPressed: () => context.push('/auth/login'),
              child: const Text(
                '로그인',
                style: TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (authState == AuthState.signedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 환영 메시지
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState == AuthState.signedIn ? '안녕하세요!' : '게스트로 이용 중',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authState == AuthState.signedIn 
                          ? '최근 방 목록을 확인해보세요'
                          : '게스트는 최근 3개까지만 보여요. 로그인하면 전체 보기',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 최근 방 목록
              Expanded(
                child: roomsAsync.when(
                  data: (rooms) {
                    if (rooms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 방이 없습니다',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '새 방을 만들어보세요!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index] as Room;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.1),
                              child: const Icon(
                                Icons.meeting_room,
                                color: Color(0xFF4ECDC4),
                              ),
                            ),
                            title: Text(
                              room.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              room.date ?? '날짜 미정',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              context.push('/rooms/${room.id}');
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '방 목록을 불러올 수 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoomDialog,
        backgroundColor: const Color(0xFF4ECDC4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}