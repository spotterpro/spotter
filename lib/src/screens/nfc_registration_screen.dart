// 📁 lib/src/screens/nfc_registration_screen.dart (수정본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotter/src/screens/owner/store_owner_main_screen.dart';
// 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
import 'package:firebase_auth/firebase_auth.dart'; // 누락되었던 import 구문 추가

class NfcRegistrationScreen extends StatefulWidget {
  final String applicationId;

  const NfcRegistrationScreen({
    super.key,
    required this.applicationId,
  });

  @override
  State<NfcRegistrationScreen> createState() => _NfcRegistrationScreenState();
}

class _NfcRegistrationScreenState extends State<NfcRegistrationScreen> {
  String _scanStatus = 'NFC 스캔 준비 완료';
  IconData _statusIcon = Icons.nfc;
  Color _statusColor = Colors.grey;
  bool _isRegistrationComplete = false;

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

  void _startNfcScan() async {
    // ... (내부 로직은 이전과 동일)
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _updateStatus('NFC를 지원하지 않는 기기입니다.', Icons.error_outline, Colors.red);
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            _updateStatus('NDEF 형식이 아닌 태그입니다.', Icons.warning, Colors.orange);
            await NfcManager.instance.stopSession();
            return;
          }

          final identifier = tag.data['ndef']['identifier'];
          final tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');

          _updateStatus('태그 감지 완료! 데이터베이스 등록 중...', Icons.wifi_tethering, Colors.blue);

          final storeDocRef = FirebaseFirestore.instance.collection('stores').doc(widget.applicationId);

          WriteBatch batch = FirebaseFirestore.instance.batch();

          batch.set(storeDocRef.collection('nfc_tags').doc(tagId), {
            'uid': tagId,
            'registeredAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

          batch.set(storeDocRef, {'nfcEnabled': true}, SetOptions(merge: true));

          await batch.commit();

          await NfcManager.instance.stopSession();
          _updateStatus('NFC가 가게에 성공적으로 등록되었습니다!', Icons.check_circle, Colors.green, isComplete: true);

        } catch (e) {
          await NfcManager.instance.stopSession();
          _updateStatus('등록 중 오류 발생: ${e.toString()}', Icons.error, Colors.red);
        }
      },
      onError: (e) async {
        _updateStatus('NFC 스캔 오류: ${e.message}', Icons.error, Colors.red);
      },
    );
    _updateStatus('NFC를 휴대폰 뒷면에 태그해주세요.', Icons.nfc, Colors.blue);
  }

  void _updateStatus(String message, IconData icon, Color color, {bool isComplete = false}) {
    if (mounted) {
      setState(() {
        _scanStatus = message;
        _statusIcon = icon;
        _statusColor = color;
        _isRegistrationComplete = isComplete;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC 등록'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_statusIcon, size: 100, color: _statusColor),
              const SizedBox(height: 24),
              Text(
                _scanStatus,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isRegistrationComplete)
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('forceStoreMode', true);

                    if (mounted) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => StoreOwnerMainScreen(user: user),
                          ),
                              (route) => false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  ),
                  child: const Text('가게 관리하러 가기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}