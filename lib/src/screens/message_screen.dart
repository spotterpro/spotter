import 'package:flutter/material.dart';
import 'package:spotter/src/screens/chat_detail_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange[400],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange[400],
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: '일반'),
            Tab(text: '비즈니스'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralMessageList(),
          _buildBusinessList(),
        ],
      ),
    );
  }

  Widget _buildGeneralMessageList() {
    final conversations = [
      {'userName': '먹깨비', 'userImageSeed': 'user2', 'lastMessage': '다음에 같이 가시죠!', 'time': '어제', 'unreadCount': 1, 'messages': []},
      {'userName': '헬창', 'userImageSeed': 'user3', 'lastMessage': '넵 확인했습니다.', 'time': '2일 전', 'unreadCount': 0, 'messages': []},
    ];
    return ListView.separated(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final convo = conversations[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://picsum.photos/seed/${convo['userImageSeed']}/100/100'),
          ),
          title: Text(convo['userName'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(convo['lastMessage'] as String, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: _buildTrailing(convo['time'] as String, convo['unreadCount'] as int),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(
              userName: convo['userName'] as String,
              userImageSeed: convo['userImageSeed'] as String,
              messages: (convo['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [],
            )));
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 88),
    );
  }

  Widget _buildBusinessList() {
    final businessConvos = [
      {'userName': '맛집 파스타 사장님', 'userImageSeed': 'pasta', 'lastMessage': '✨ 스폰서쉽 제안이 도착했습니다.', 'time': '오후 11:58', 'unreadCount': 1,
        'messages': [
          {'sender': 'store', 'text': '안녕하세요, 스포터님!'},
          {'sender': 'store', 'type': 'proposal', 'reward': '여름 시즌 음료 무제한 이용권', 'mission': '빙수 챌린지 1회 개최', 'status': 'pending'},
        ]
      },
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: businessConvos.length,
      itemBuilder: (context, index) {
        final convo = businessConvos[index];
        final isSponsorship = (convo['lastMessage'] as String).contains('스폰서쉽');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
          shadowColor: Colors.black12,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage('https://picsum.photos/seed/${convo['userImageSeed']}/100/100'),
                ),
                Positioned(
                  bottom: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                    child: Icon(Icons.storefront, color: Colors.blue[600], size: 16),
                  ),
                )
              ],
            ),
            title: Text(convo['userName'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                convo['lastMessage'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isSponsorship ? Colors.blue[600] : Colors.grey[600],
                    fontWeight: isSponsorship ? FontWeight.bold : FontWeight.normal
                )
            ),
            trailing: _buildTrailing(convo['time'] as String, convo['unreadCount'] as int),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(
                userName: convo['userName'] as String,
                userImageSeed: convo['userImageSeed'] as String,
                messages: (convo['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [],
              )));
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
    );
  }

  Widget _buildTrailing(String time, int unreadCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        if (unreadCount > 0)
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.orange[400],
            child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
          )
        else
          const SizedBox(height: 20),
      ],
    );
  }
}