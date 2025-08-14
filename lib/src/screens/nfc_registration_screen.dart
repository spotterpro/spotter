// 📁 lib/src/screens/nfc_registration_screen.dart (최종 수정본)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:spotter/src/screens/owner/store_management_screen.dart';

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
    NfcManager.instance.stopSession().catchError((_) { /* 에러 무시 */ });
    super.dispose();
  }

  void _startNfcScan() async {
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

          _updateStatus('태그 감지 완료! 데이터베이스 확인 중...', Icons.wifi_tethering, Colors.blue);

          final appDocRef = FirebaseFirestore.instance.collection('store_applications').doc(widget.applicationId);
          final existingTag = await appDocRef.collection('nfc_tags').doc(tagId).get();

          if (existingTag.exists) {
            _updateStatus('이미 이 가게에 등록된 스티커입니다.', Icons.check_circle, Colors.green, isComplete: true);
            await NfcManager.instance.stopSession();
            return;
          }

          _updateStatus('데이터베이스에 등록 중...', Icons.wifi_tethering, Colors.blue);

          await appDocRef.collection('nfc_tags').doc(tagId).set({
            'uid': tagId,
            'registeredAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

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
                  // 🔥🔥🔥 --- 바로 이 부분입니다, 형님! --- 🔥🔥🔥
                  // 'pop' 대신 'pushAndRemoveUntil'을 사용하여 모든 이전 화면을 닫고
                  // 가게 관리 대시보드로 한번에 이동시킵니다.
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => StoreManagementScreen(storeId: widget.applicationId),
                      ),
                          (route) => route.isFirst, // 가장 첫 화면(MainScreen)만 남기고 모두 제거
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  ),
                  child: const Text('가게 관리하러 가기'),
                )
              else if (_scanStatus.contains('태그해주세요'))
                Text(
                  'NFC가 인식되면 자동으로 등록이 완료됩니다.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}