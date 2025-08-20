// 📁 lib/src/screens/nfc_registration_screen.dart (UX 개선 최종본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:spotter/services/mode_prefs.dart';
import 'package:spotter/src/screens/owner/store_owner_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // UI 상태를 관리하기 위한 변수들
  bool _isScanning = false; // 스캔 시작 여부
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
    // 스캔 시작 상태로 UI 변경
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
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            _updateStatus('NDEF 형식이 아닌 태그입니다.', Icons.warning, Colors.orange);
            await NfcManager.instance.stopSession();
            return;
          }

          final identifier = tag.data['ndef']['identifier'];
          final tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');

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
        _subStatusMessage = ''; // 스캔 시작 후에는 서브 메시지 없음
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

              // UI 로직: 상태에 따라 다른 버튼을 보여줍니다.
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
                  onPressed: _startNfcScan, // 버튼을 눌러야만 스캔이 시작됩니다.
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