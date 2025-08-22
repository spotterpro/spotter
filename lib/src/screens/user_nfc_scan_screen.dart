// 📁 lib/src/screens/user_nfc_scan_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:spotter/main.dart'; // 🔥🔥🔥 'mainScreenNavigator'를 사용하기 위해 임포트합니다.

class UserNfcScanScreen extends StatefulWidget {
  final String storeId;
  final String rewardId;
  final Map<String, dynamic> rewardData;

  const UserNfcScanScreen({
    super.key,
    required this.storeId,
    required this.rewardId,
    required this.rewardData,
  });

  @override
  State<UserNfcScanScreen> createState() => _UserNfcScanScreenState();
}

class _UserNfcScanScreenState extends State<UserNfcScanScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  ValueNotifier<NfcStatus> status = ValueNotifier(NfcStatus.ready);
  ValueNotifier<String> statusMessage = ValueNotifier('가게의 NFC 스탬프에 휴대폰을 태그해주세요.');

  @override
  void initState() {
    super.initState();
    _startNfcScan();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession().catchError((_) {});
    super.dispose();
  }

  void _startNfcScan() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        status.value = NfcStatus.processing;
        statusMessage.value = 'NFC 태그 확인 중...';

        final ndef = Ndef.from(tag);
        if (ndef == null) throw Exception('유효하지 않은 NFC 태그입니다.');

        final tagId = tag.data['ndef']['identifier']
            .map((e) => e.toRadixString(16).padLeft(2, '0')).join('');

        final validTagRef = _db.collection('stores').doc(widget.storeId).collection('nfc_tags').doc(tagId);
        final validTagDoc = await validTagRef.get();
        if (!validTagDoc.exists) throw Exception('해당 가게에 등록되지 않은 스탬프입니다.');

        statusMessage.value = '스탬프 확인 완료! 보상을 처리합니다...';
        await _processReward();
        await NfcManager.instance.stopSession();
      } catch (e) {
        await NfcManager.instance.stopSession();
        status.value = NfcStatus.error;
        statusMessage.value = '오류: ${e.toString().replaceAll('Exception: ', '')}';
      }
    });
  }

  Future<void> _checkCooldown() async {
    // 이 함수는 현재 로직에서 호출되지 않지만, 나중에 필요할 수 있으므로 남겨둡니다.
  }

  Future<void> _processReward() async {
    final challengeRef = _db.collection('users').doc(_currentUserId).collection('ongoing_rewards').doc(widget.rewardId);
    final challengeDoc = await challengeRef.get();

    if (!challengeDoc.exists) {
      await challengeRef.set({
        'rewardData': widget.rewardData,
        'storeId': widget.storeId,
        'progress': 0,
        'startedAt': FieldValue.serverTimestamp(),
      });
    }

    await _db.collection('users').doc(_currentUserId).collection('stamps').add({
      'storeId': widget.storeId,
      'rewardId': widget.rewardId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await challengeRef.update({'progress': FieldValue.increment(1)});
    final updatedChallengeDoc = await challengeRef.get();
    final newProgress = updatedChallengeDoc.data()?['progress'] ?? 0;
    final requiredStamps = widget.rewardData['requiredStamps'] ?? 1;

    if (newProgress >= requiredStamps) {
      final couponRef = _db.collection('users').doc(_currentUserId).collection('coupons').doc();
      WriteBatch batch = _db.batch();
      batch.set(couponRef, {
        'rewardData': widget.rewardData,
        'storeId': widget.storeId,
        'createdAt': FieldValue.serverTimestamp(),
        'usedAt': null,
      });
      batch.delete(challengeRef);
      await batch.commit();

      status.value = NfcStatus.success;
      statusMessage.value = '성공! \'${widget.rewardData['title']}\' 쿠폰을 획득했습니다!';

      if(mounted) {
        await Future.delayed(const Duration(seconds: 2));
        mainScreenNavigator.value = 2; // 스탬프 탭(인덱스 2)으로 이동하라는 신호
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      status.value = NfcStatus.success;
      statusMessage.value = '스탬프 적립 완료! ($newProgress / $requiredStamps)';
      if(mounted) {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스탬프 찍기')),
      body: Center(
        child: ValueListenableBuilder<NfcStatus>(
          valueListenable: status,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getIconForStatus(value), size: 100, color: _getColorForStatus(value)),
                const SizedBox(height: 24),
                ValueListenableBuilder<String>(
                  valueListenable: statusMessage,
                  builder: (context, message, child) {
                    return Text(message, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForStatus(NfcStatus status) {
    switch (status) {
      case NfcStatus.ready: return Icons.nfc;
      case NfcStatus.processing: return Icons.wifi_tethering;
      case NfcStatus.success: return Icons.check_circle;
      case NfcStatus.error: return Icons.error;
    }
  }

  Color _getColorForStatus(NfcStatus status) {
    switch (status) {
      case NfcStatus.ready: return Colors.blue;
      case NfcStatus.processing: return Colors.blue;
      case NfcStatus.success: return Colors.green;
      case NfcStatus.error: return Colors.red;
    }
  }
}

enum NfcStatus { ready, processing, success, error }