// 📁 lib/src/screens/coupon_redemption_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class CouponRedemptionScreen extends StatefulWidget {
  final String couponId;
  final String storeId;

  const CouponRedemptionScreen({
    super.key,
    required this.couponId,
    required this.storeId,
  });

  @override
  State<CouponRedemptionScreen> createState() => _CouponRedemptionScreenState();
}

class _CouponRedemptionScreenState extends State<CouponRedemptionScreen> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  ValueNotifier<String> statusMessage = ValueNotifier('쿠폰을 사용하려면 가게의 NFC 스탬프에 태그해주세요.');

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
        statusMessage.value = 'NFC 태그 확인 중...';
        final ndef = Ndef.from(tag);
        if (ndef == null) throw Exception('유효하지 않은 NFC 태그입니다.');
        final tagId = tag.data['ndef']['identifier'].map((e) => e.toRadixString(16).padLeft(2, '0')).join('');

        final validTagRef = FirebaseFirestore.instance.collection('stores').doc(widget.storeId).collection('nfc_tags').doc(tagId);
        final validTagDoc = await validTagRef.get();
        if (!validTagDoc.exists) throw Exception('해당 가게에 등록되지 않은 스탬프입니다.');

        statusMessage.value = '인증 성공! 쿠폰을 사용 처리합니다...';

        final couponRef = FirebaseFirestore.instance.collection('users').doc(_currentUserId).collection('coupons').doc(widget.couponId);
        await couponRef.update({'usedAt': FieldValue.serverTimestamp()});

        await NfcManager.instance.stopSession();
        statusMessage.value = '쿠폰 사용이 완료되었습니다!';

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // --- 🔥🔥🔥 수정된 부분: 성공했다는 의미로 true 값을 돌려줍니다. ---
          Navigator.of(context).pop(true);
        }

      } catch (e) {
        await NfcManager.instance.stopSession();
        statusMessage.value = '오류: ${e.toString()}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('쿠폰 사용하기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            ValueListenableBuilder<String>(
              valueListenable: statusMessage,
              builder: (context, message, child) {
                return Text(message, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center);
              },
            ),
          ],
        ),
      ),
    );
  }
}