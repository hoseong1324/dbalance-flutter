import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  final _roomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _loadRooms();
  }

  Future<void> _initializeAuth() async {
    await AuthService().initialize();
    setState(() {}); // UI 업데이트
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final rooms = await ApiService().getRecentRooms();
      
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('방 목록 로드 실패: $e');
    }
  }

  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      _showSnackBar('방 이름을 입력해주세요');
      return;
    }

    try {
      await ApiService().createRoom(name: _roomNameController.text.trim());
      
      _showSnackBar('방이 생성되었습니다!');
      _roomNameController.clear();
      Navigator.of(context).pop();
      _loadRooms(); // 방 목록 새로고침
    } catch (e) {
      _showSnackBar('방 생성 실패: $e');
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
              Navigator.of(context).pop();
              _roomNameController.clear();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: _createRoom,
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          AuthService().isLoggedIn
              ? PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await AuthService().logout();
                      setState(() {});
                      _showSnackBar('로그아웃되었습니다');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text(AuthService().userDisplayName ?? '마이페이지'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout),
                          const SizedBox(width: 8),
                          const Text('로그아웃'),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF4ECDC4),
                          child: Text(
                            (AuthService().userDisplayName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AuthService().userDisplayName ?? '마이페이지',
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF4ECDC4),
                        ),
                      ],
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 환영 메시지 (게스트일 때만 표시)
              if (!AuthService().isLoggedIn) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '게스트로 이용 중',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '게스트는 최근 3개까지만 보여요. 로그인하면 전체 보기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // 새로고침 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근 방 목록',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadRooms,
                    icon: Icon(
                      Icons.refresh,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 최근 방 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _rooms.isEmpty
                        ? Center(
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
                          )
                        : ListView.builder(
                            itemCount: _rooms.length,
                            itemBuilder: (context, index) {
                              final room = _rooms[index];
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
                                    room['name'] ?? '방 이름 없음',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    room['date'] ?? '날짜 미정',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    final roomId = room['id'];
                                    if (roomId != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RoomDetailScreen(
                                            roomId: roomId,
                                            roomName: room['name'] ?? '방',
                                          ),
                                        ),
                                      );
                                    } else {
                                      _showSnackBar('방 ID를 찾을 수 없습니다');
                                    }
                                  },
                                ),
                              );
                            },
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