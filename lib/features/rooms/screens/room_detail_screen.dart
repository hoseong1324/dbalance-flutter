import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../shared/models/room.dart';
import '../../../shared/models/participant.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  final int roomId;

  const RoomDetailScreen({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Room? _room;
  List<Round> _rounds = [];
  List<RoomParticipant> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRoomData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    try {
      setState(() => _isLoading = true);
      
      final room = await ref.read(roomsRepositoryProvider).getRoom(widget.roomId);
      final rounds = await ref.read(roomsRepositoryProvider).getRounds(widget.roomId);
      
      setState(() {
        _room = room;
        _rounds = rounds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _addRound() async {
    final placeNameController = TextEditingController();
    final memoController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 라운드 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: placeNameController,
              decoration: const InputDecoration(
                labelText: '장소명 (선택사항)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: '메모 (선택사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
            ),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final round = await ref.read(roomsRepositoryProvider).createRound(
          widget.roomId,
          placeName: placeNameController.text.trim().isNotEmpty 
              ? placeNameController.text.trim() 
              : null,
          memo: memoController.text.trim().isNotEmpty 
              ? memoController.text.trim() 
              : null,
        );

        setState(() {
          _rounds.add(round);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('라운드가 추가되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('라운드 추가 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_room == null) {
      return const Scaffold(
        body: Center(
          child: Text('방 정보를 불러올 수 없습니다'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _room!.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4ECDC4),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4ECDC4),
          tabs: const [
            Tab(text: '라운드'),
            Tab(text: '참가자'),
            Tab(text: '정산'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoundsTab(),
          _buildParticipantsTab(),
          _buildSettlementTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRound,
        backgroundColor: const Color(0xFF4ECDC4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRoundsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rounds.length,
      itemBuilder: (context, index) {
        final round = _rounds[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4ECDC4),
              child: Text(
                '${round.roundNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              round.placeName ?? '라운드 ${round.roundNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: round.memo != null 
                ? Text(round.memo!)
                : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 라운드 상세 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('라운드 ${round.roundNumber} 상세 화면 (구현 예정)')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildParticipantsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '참가자 관리',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '참가자 추가/수정 기능 (구현 예정)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '정산 결과',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '정산 계산 기능 (구현 예정)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
