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

  // --- 형님의 요청대로 수정된 부분 ---
  String get levelTitle => 'LV.$level';

  String get influenceTitle {
    if (influence >= 1000) {
      return '스팟 인플루언서';
    } else if (influence >= 500) {
      return '골목대장';
    } else if (influence >= 250) {
      return '단골손님';
    } else if (influence >= 100) {
      return '동네 주민';
    } else {
      return '새싹 스포터';
    }
  }

  String get levelWithInfluenceTitle => '$levelTitle $influenceTitle';


  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      userName: data['userName'] ?? '사용자',
      userImageSeed: data['userImageSeed'] ?? 'defaultUser',
      bio: data['bio'] ?? '',
      xp: data['xp'] ?? 0,
      crewCount: data['crewCount'] ?? 0,
      myCrewCount: data['myCrewCount'] ?? 0,
      influence: data['influence'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': userName,
      'userName': userName,
      'levelTitle': levelWithInfluenceTitle,
      'userImageSeed': userImageSeed,
      'bio': bio,
      'xp': xp,
      'crewCount': crewCount,
      'myCrewCount': myCrewCount,
      'influence': influence,
    };
  }
}