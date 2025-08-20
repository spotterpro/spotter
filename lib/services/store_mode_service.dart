// 📁 lib/services/store_mode_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModeService {
  final String uid;
  StreamSubscription? _statusSubscription;

  StoreModeService({required this.uid});

  /// [수정됨] 사용자의 정확한 가게 상태를 문자열로 반환하는 새로운 함수
  /// 반환값: "approved", "pending", "rejected", "none"
  Future<String> getStoreStatus() async {
    if (uid.isEmpty) return 'none';

    final docRef = FirebaseFirestore.instance.collection('stores').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      // 문서가 존재하면 status 필드 값을 반환합니다.
      return doc.data()?['status'] ?? 'pending'; // status 필드가 없으면 'pending'으로 간주
    } else {
      // 문서가 없으면 신청한 적이 없는 것입니다.
      return 'none';
    }
  }

  // 이하는 기존 코드입니다. 지금 당장 사용되지는 않지만 그대로 둡니다.
  Future<bool> shouldEnterStoreMode() async {
    final docRef = FirebaseFirestore.instance.collection('stores').doc(uid);
    final doc = await docRef.get();
    return doc.exists && doc.data()?['status'] == 'approved';
  }

  void listenForStatusChanges({required Function onDeauthorized}) {
    final docRef = FirebaseFirestore.instance.collection('stores').doc(uid);
    _statusSubscription = docRef.snapshots().listen((doc) {
      if (!doc.exists || doc.data()?['status'] != 'approved') {
        onDeauthorized();
      }
    });
  }

  void dispose() {
    _statusSubscription?.cancel();
  }
}