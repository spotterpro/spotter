import 'package:flutter/material.dart';
import 'package:spotter/features/user/presentation/screens/user_profile_screen.dart';
import 'package:spotter/features/write_post/presentation/screens/write_community_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '스팟 커뮤니티',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildFilterBar(context),
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

  Widget _buildFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 28),
            const SizedBox(width: 16),
            _buildFilterChip(context, "🔥 주간 인기글", isHot: true),
            _buildFilterChip(context, "#전체", isSelected: true),
            _buildFilterChip(context, "#맛집탐방"),
            _buildFilterChip(context, "#오운완"),
            _buildFilterChip(context, "#동네소식"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false, bool isHot = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color unselectedColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color selectedTextColor = isDarkMode ? Colors.black : Colors.white;
    final Color unselectedTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: unselectedColor,
        selectedColor: isHot ? Colors.deepOrange : (isDarkMode ? Colors.white : Colors.black),
        labelStyle: TextStyle(
          color: isSelected ? selectedTextColor : unselectedTextColor,
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
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
            _buildHashtags(context, ['#맛집탐방', '#동성로']),
            const SizedBox(height: 16),
            _buildPostActions(context, likes: 45, comments: 1),
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
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
            _buildPollOption(context, "헬스 클럽 (수성구)"),
            const SizedBox(height: 8),
            _buildPollOption(context, "요가 스튜디오 (남구)"),
            const SizedBox(height: 12),
            _buildHashtags(context, ['#오운완', '#운동']),
            const SizedBox(height: 16),
            _buildPostActions(context, likes: 12, comments: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPollOption(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          const CircleAvatar(radius: 22),
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

  Widget _buildHashtags(BuildContext context, List<String> tags) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color chipBackgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags
          .map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: chipBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(tag, style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 12)),
      ))
          .toList(),
    );
  }

  Widget _buildPostActions(BuildContext context, {required int likes, required int comments}) {
    final Color iconTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return Row(
      children: [
        Icon(Icons.favorite_border, color: iconTextColor, size: 20),
        const SizedBox(width: 4),
        Text('좋아요 $likes', style: TextStyle(color: iconTextColor, fontSize: 14)),
        const SizedBox(width: 16),
        Icon(Icons.chat_bubble_outline, color: iconTextColor, size: 20),
        const SizedBox(width: 4),
        Text(comments > 0 ? '댓글 ($comments)' : '댓글', style: TextStyle(color: iconTextColor, fontSize: 14)),
      ],
    );
  }
}