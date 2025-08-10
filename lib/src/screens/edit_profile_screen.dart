import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentNickname;
  final String currentBio;

  const EditProfileScreen({
    super.key,
    required this.currentNickname,
    required this.currentBio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;

  // 선택 가능한 전체 관심사 목록
  final List<String> _allInterests = [
    '#맛집탐방', '#카페투어', '#산책', '#운동', '#사진찍기', '#여행', '#쇼핑', '#독서', '#영화감상'
  ];

  // 사용자가 선택한 관심사 목록
  final Set<String> _selectedInterests = {'#맛집탐방', '#운동'};

  // 서버에 이미 등록된 닉네임 목록 (시뮬레이션용)
  final List<String> _takenNicknames = ['스포터', '동네주민', '먹깨비'];

  bool _isNicknameChecked = true;
  String _nicknameCheckMessage = '';
  Color _nicknameMessageColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _bioController = TextEditingController(text: widget.currentBio);

    _nicknameController.addListener(() {
      if (_nicknameController.text.trim() != widget.currentNickname) {
        if (mounted) {
          setState(() {
            _isNicknameChecked = false;
            _nicknameCheckMessage = '';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _checkNickname() {
    final nickname = _nicknameController.text.trim();
    setState(() {
      if (nickname.length < 2) {
        _isNicknameChecked = false;
        _nicknameCheckMessage = '닉네임은 2글자 이상이어야 합니다.';
        _nicknameMessageColor = Colors.red;
      } else if (_takenNicknames.contains(nickname)) {
        _isNicknameChecked = false;
        _nicknameCheckMessage = '이미 사용 중인 닉네임입니다.';
        _nicknameMessageColor = Colors.red;
      } else {
        _isNicknameChecked = true;
        _nicknameCheckMessage = '사용 가능한 닉네임입니다.';
        _nicknameMessageColor = Colors.green;
      }
    });
  }

  void _saveProfile() {
    final newNickname = _nicknameController.text.trim();
    if (_isNicknameChecked || newNickname == widget.currentNickname) {
      final newProfile = {
        'nickname': newNickname,
        'bio': _bioController.text.trim(),
      };
      Navigator.pop(context, newProfile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임 중복 확인을 해주세요.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNicknameUnchanged = _nicknameController.text == widget.currentNickname;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: (isNicknameUnchanged || _isNicknameChecked) ? _saveProfile : null,
            child: Text('완료', style: TextStyle(
              fontSize: 16,
              color: (isNicknameUnchanged || _isNicknameChecked) ? Colors.orange : Colors.grey,
            )),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://picsum.photos/seed/myprofile/200/200'),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: CircleAvatar(
                    radius: 18, backgroundColor: Theme.of(context).colorScheme.onSurface,
                    child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.surface, size: 20),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _checkNickname,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: const Text('중복 확인'),
              ),
            ],
          ),
          if (_nicknameCheckMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0),
              child: Text(
                _nicknameCheckMessage,
                style: TextStyle(color: _nicknameMessageColor, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: '자기소개', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          const Text('관심사', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _allInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return ChoiceChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}