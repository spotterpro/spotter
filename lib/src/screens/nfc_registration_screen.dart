// 📁 lib/src/screens/nfc_registration_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/src/screens/owner/store_owner_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/utils/nfc_utils.dart'; // 🔥🔥🔥 새로 만든 유틸리티를 임포트합니다.

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
  bool _isScanning = false;
  String _statusMessage = '가게 승인이 완료되었습니다.';
  String _subStatusMessage = '배송된 NFC 스탬프를 아래 버튼을 눌러 등록을 시작해주세요.';
  IconData _statusIcon = Icons.store_mall_directory_rounded;
  Color _statusColor = Colors.blue;
  bool _isRegistrationComplete = false;

  @override
  void dispose() {
    NfcManager.instance.stopSession().catchError((_) {});
    super.dispose();
  }

  void _startNfcScan() async {
    setState(() {
      _isScanning = true;
      _updateStatus('NFC를 휴대폰 뒷면에 태그해주세요.', Icons.nfc, Colors.blue);
    });

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _updateStatus('NFC를 지원하지 않는 기기입니다.', Icons.error_outline, Colors.red);
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // --- 🔥🔥🔥 새로운 NFC ID 인식 로직을 사용합니다. ---
          final tagId = getConsistentNfcId(tag);
          if (tagId == null) {
            throw Exception('NFC 태그 ID를 읽을 수 없습니다.');
          }

          _updateStatus('태그 감지 완료!\n데이터베이스 등록 중...', Icons.wifi_tethering, Colors.blue);

          final storeDocRef = FirebaseFirestore.instance.collection('stores').doc(widget.applicationId);
          WriteBatch batch = FirebaseFirestore.instance.batch();

          batch.set(storeDocRef.collection('nfc_tags').doc(tagId), {
            'uid': tagId,
            'registeredAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

          batch.update(storeDocRef, {
            'nfcEnabled': true,
            'status': 'approved',
          });

          await batch.commit();
          await ModePrefs.setStoreMode(true);
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
  }

  void _updateStatus(String message, IconData icon, Color color, {bool isComplete = false}) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
        _subStatusMessage = '';
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
        title: const Text('NFC 스탬프 등록'),
        automaticallyImplyLeading: false,
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
                _statusMessage,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (_subStatusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _subStatusMessage,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 48),
              if (_isRegistrationComplete)
                ElevatedButton(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => StoreOwnerMainScreen(user: user),
                          ), (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('가게 관리 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              else if (!_isScanning)
                ElevatedButton(
                  onPressed: _startNfcScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('NFC 등록 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}