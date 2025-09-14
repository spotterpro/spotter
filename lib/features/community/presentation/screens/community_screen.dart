import 'package:flutter/material.dart';
// [수정] 파일 이동에 따른 import 경로 변경
import 'package:spotter/features/write_post/presentation/screens/write_community_post_screen.dart';
import 'package:spotter/features/user/presentation/screens/user_profile_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '스팟 커뮤니티',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              _buildFilterBar(),
              _buildTextPost(context),
              _buildPollPost(context),
              _buildTextPost(context),
            ],
          ),
          _buildWriteButton(context),
        ],
      ),
    );
  }

  Widget _buildWriteButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WriteCommunityPostScreen()),
          );
        },
        backgroundColor: const Color(0xFFFFA726),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 28),
            const SizedBox(width: 16),
            _buildFilterChip("🔥 주간 인기글", isHot: true),
            _buildFilterChip("#전체", isSelected: true),
            _buildFilterChip("#맛집탐방"),
            _buildFilterChip("#오운완"),
            _buildFilterChip("#동네소식"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, bool isHot = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: Colors.grey[200],
        selectedColor: isHot ? Colors.deepOrange : Colors.black,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        showCheckmark: false,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildTextPost(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(name: "먹깨비", level: "LV.50", time: "2025-09-13T10:37:50.762Z", context: context),
            const SizedBox(height: 16),
            const Text(
              '동성로에 새로 생긴 맛집 파스타 진짜 맛있네요! 인생 파스타 등극입니다 ㅠㅠ 다들 꼭 가보세요!',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildHashtags(['#맛집탐방', '#동성로']),
            const SizedBox(height: 16),
            _buildPostActions(likes: 45, comments: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildPollPost(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(name: "헬창", level: "LV.35", time: "2025-09-12T13:37:50.762Z", context: context),
            const SizedBox(height: 16),
            const Text(
              '주말에 운동 어디로 갈까요?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPollOption("헬스 클럽 (수성구)"),
            const SizedBox(height: 8),
            _buildPollOption("요가 스튜디오 (남구)"),
            const SizedBox(height: 12),
            _buildHashtags(['#오운완', '#운동']),
            const SizedBox(height: 16),
            _buildPostActions(likes: 12, comments: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPollOption(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUserProfile({required String name, required String level, required String time, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const UserProfileScreen()),
        );
      },
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(level, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHashtags(List<String> tags) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags
          .map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(tag, style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 12)),
      ))
          .toList(),
    );
  }

  Widget _buildPostActions({required int likes, required int comments}) {
    return Row(
      children: [
        Icon(Icons.favorite_border, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 4),
        Text('좋아요 $likes', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(width: 16),
        Icon(Icons.chat_bubble_outline, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 4),
        Text(comments > 0 ? '댓글 ($comments)' : '댓글', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }
}