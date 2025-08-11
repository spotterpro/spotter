// 📁 lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class UserProfile {
  final String uid;
  final String email;
  final String userName;
  final String userImageSeed;
  final String bio;
  final int xp;
  final int crewCount;
  final int myCrewCount;
  final int influence;

  UserProfile({
    required this.uid,
    required this.email,
    required this.userName,
    this.userImageSeed = 'defaultUser',
    this.bio = '',
    this.xp = 0,
    this.crewCount = 0,
    this.myCrewCount = 0,
    this.influence = 0,
  });

  int get level => (0.1 * sqrt(xp)).floor() + 1;
  int get currentLevelXp => pow(((level - 1) / 0.1), 2).toInt();
  int get nextLevelXp => pow((level / 0.1), 2).toInt();
  int get xpForNextLevel => nextLevelXp - currentLevelXp;
  int get currentXpInLevel => xp - currentLevelXp;
  double get levelProgress => xpForNextLevel == 0 ? 0 : currentXpInLevel / xpForNextLevel;
  String get levelTitle => 'LV.$level';

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      userName: data['userName'] ?? '사용자', // Firestore의 필드명은 'userName'으로 유지
      userImageSeed: data['userImageSeed'] ?? 'defaultUser',
      bio: data['bio'] ?? '',
      xp: data['xp'] ?? 0,
      crewCount: data['crewCount'] ?? 0,
      myCrewCount: data['myCrewCount'] ?? 0,
      influence: data['influence'] ?? 0,
    );
  }

  // --- 형님의 요청대로 수정된 부분 ---
  // FeedCard에서 사용하는 'name' 키에 맞춰 데이터를 변환합니다.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': userName, // 'userName'을 'name'으로 매핑
      'userName': userName, // 기존 호환성을 위해 유지
      'levelTitle': levelTitle,
      'userImageSeed': userImageSeed,
      'bio': bio,
      'xp': xp,
      'crewCount': crewCount,
      'myCrewCount': myCrewCount,
      'influence': influence,
    };
  }
}