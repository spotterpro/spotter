// 📁 lib/src/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:spotter/src/screens/user_profile_screen.dart'; // UserProfileScreen 임포트

class ChatDetailScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String otherUserImageSeed;

  const ChatDetailScreen({
    Key? key,
    required this.chatRoomId,
    required this.otherUserName,
    required this.otherUserImageSeed,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': '안녕하세요! 스탬프 투어 문의 드립니다.', 'isMe': false, 'senderId': 'other_user_id'},
    {'text': '네 안녕하세요! 어떤게 궁금하신가요?', 'isMe': true, 'senderId': 'my_user_id'},
    {'text': '동네 카페 투어 리워드가 정확히 뭔가요?', 'isMe': false, 'senderId': 'other_user_id'},
    {'text': '아, 그건 저희가 직접 로스팅한 원두 200g을 드리고 있습니다!', 'isMe': true, 'senderId': 'my_user_id'},
  ];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _messageController.text, 'isMe': true, 'senderId': 'my_user_id'});
        _messageController.clear();
      });
      // TODO: Firestore에 메시지 전송 로직 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['isMe'] as bool;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // --- 형님의 요청대로 수정된 부분 ---
                    // UserProfileScreen으로 senderId를 전달합니다.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: message['senderId'] as String)));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('https://picsum.photos/seed/${widget.otherUserImageSeed}/100/100'),
                  ),
                ),
              ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isMe ? Colors.orange[400] : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  message['text'] as String,
                  style: TextStyle(
                    color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: () {},
              color: Colors.grey[600],
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '메시지 입력...',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
              color: Colors.orange[600],
            ),
          ],
        ),
      ),
    );
  }
}