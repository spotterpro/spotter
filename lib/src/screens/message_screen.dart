// 📁 lib/src/screens/message_screen.dart

import 'package:flutter/material.dart';
import 'package:spotter/src/screens/chat_detail_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 'chat1',
      'userName': '맛집 파스타',
      'userImage': 'pasta',
      'lastMessage': '네, 예약 가능합니다! 언제쯤 방문 예정이신가요?',
      'timestamp': '오후 2:30',
      'unreadCount': 1,
    },
    {
      'id': 'chat2',
      'userName': '클린 세탁소',
      'userImage': 'laundry',
      'lastMessage': '맡기신 운동화 찾아가세요~',
      'timestamp': '오전 11:15',
      'unreadCount': 0,
    },
  ];

  final List<Map<String, dynamic>> _archivedConversations = [
    {
      'id': 'chat3',
      'userName': '카페 스프링',
      'userImage': 'cafe',
      'lastMessage': '쿠폰 사용해주셔서 감사합니다!',
      'timestamp': '어제',
      'unreadCount': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('메시지'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '채팅'),
              Tab(text: '보관'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildConversationList(_conversations),
            _buildConversationList(_archivedConversations, isArchived: true),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList(List<Map<String, dynamic>> conversations, {bool isArchived = false}) {
    if (conversations.isEmpty) {
      return Center(
        child: Text(
          isArchived ? '보관된 메시지가 없습니다.' : '메시지가 없습니다.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return ListView.separated(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final convo = conversations[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://picsum.photos/seed/${convo['userImage']}/100/100'),
          ),
          title: Text(
            convo['userName'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            convo['lastMessage'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                convo['timestamp'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              if (convo['unreadCount'] > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${convo['unreadCount']}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else
                const SizedBox(height: 16), // unreadCount가 없을 때 공간 차지
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatRoomId: convo['id'] as String,
                  // --- 형님의 요청대로 수정된 부분 ---
                  // 파라미터 이름을 새 규격에 맞게 변경합니다.
                  otherUserName: convo['userName'] as String,
                  otherUserImageSeed: convo['userImage'] as String,
                ),
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 80,
        endIndent: 16,
      ),
    );
  }
}