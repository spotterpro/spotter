import 'package:flutter/material.dart';
import 'package:spotter/src/screens/user_profile_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String userImageSeed;
  final List<Map<String, dynamic>> messages;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.userImageSeed,
    required this.messages,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late List<Map<String, dynamic>> _messages;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'me',
        'text': _textController.text.trim(),
      });
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://picsum.photos/seed/${widget.userImageSeed}/100/100'),
            ),
            const SizedBox(width: 12),
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message['type'] == 'proposal') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildProposalCard(message),
                  );
                }
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['sender'] == 'me';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfileScreen()));
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://picsum.photos/seed/${widget.userImageSeed}/100/100'),
              ),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              margin: isMe ? const EdgeInsets.only(left: 48) : const EdgeInsets.only(right: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.orange[400] : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message['text'],
                style: TextStyle(color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✨ 스폰서쉽 제안', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            Text('제공 리워드: ${proposal['reward']}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('요청 미션: ${proposal['mission']}'),
            const SizedBox(height: 16),
            if (proposal['status'] == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { setState(() { proposal['status'] = 'accepted'; }); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('수락'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () { setState(() { proposal['status'] = 'declined'; }); },
                      child: const Text('거절'),
                    ),
                  ),
                ],
              )
            else if (proposal['status'] == 'accepted')
              Center(child: Text('✅ 제안을 수락했습니다.', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)))
            else
              Center(child: Text('❌ 제안을 거절했습니다.', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(onPressed: (){}, icon: const Icon(Icons.add_circle_outline)),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: '메시지 보내기...',
                  border: InputBorder.none,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: Colors.orange[400]),
            ),
          ],
        ),
      ),
    );
  }
}