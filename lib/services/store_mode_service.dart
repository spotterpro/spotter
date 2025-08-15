// 📁 lib/services/store_mode_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotter/services/mode_prefs.dart';

class StoreModeService {
  final String uid;
  StreamSubscription? _statusSubscription;

  StoreModeService({required this.uid});

  // 앱 시작 시, 최종적으로 어떤 모드로 시작할지 결정
  Future<bool> shouldEnterStoreMode() async {
    final hasLocalFlag = await ModePrefs.getStoreMode();
    if (!hasLocalFlag) return false;

    // 형님의 DB 구조에 맞게 'stores' 컬렉션을 확인합니다.
    final docRef = FirebaseFirestore.instance.collection('stores').doc(uid);
    final doc = await docRef.get();

    // 문서가 존재하고, nfcEnabled가 true(모든 등록 절차 완료)인지 확인
    if (doc.exists && doc.data()?['nfcEnabled'] == true) {
      return true;
    } else {
      await ModePrefs.setStoreMode(false); // 조건 미충족 시 신분증 파기
      return false;
    }
  }

  // 가게 상태 변경 실시간 감시
  void listenForStatusChanges({required Function onDeauthorized}) {
    final docRef = FirebaseFirestore.instance.collection('stores').doc(uid);
    _statusSubscription = docRef.snapshots().listen((doc) {
      if (!doc.exists || doc.data()?['nfcEnabled'] != true) {
        onDeauthorized();
      }
    });
  }

  void dispose() {
    _statusSubscription?.cancel();
  }
}