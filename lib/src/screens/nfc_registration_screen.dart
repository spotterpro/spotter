// 📁 lib/src/screens/nfc_registration_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:spotter/src/screens/owner/store_management_screen.dart';

class NfcRegistrationScreen extends StatefulWidget {
  final String storeId;

  const NfcRegistrationScreen({
    super.key,
    required this.storeId,
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

          final existingTag = await FirebaseFirestore.instance.collection('nfc_tags').doc(tagId).get();

          // 👑 --- 형님의 지시대로 재스캔 로직을 추가한 부분 --- 👑
          if (existingTag.exists) {
            final existingStoreId = existingTag.data()?['storeId'];
            if (existingStoreId == widget.storeId) {
              // 이미 내 가게에 등록된 태그: 성공으로 간주하고 동기화 메시지 표시
              _updateStatus('이미 등록된 스티커입니다. 다시 한번 동기화했습니다.', Icons.check_circle, Colors.green, isComplete: true);
              await NfcManager.instance.stopSession();
              return;
            } else {
              // 다른 가게에 등록된 태그: 에러 처리
              _updateStatus('이미 다른 가게에 등록된 NFC입니다.', Icons.error, Colors.red);
              await NfcManager.instance.stopSession();
              return;
            }
          }

          // 새 태그 등록 절차 진행
          _updateStatus('데이터베이스에 등록 중...', Icons.wifi_tethering, Colors.blue);

          await FirebaseFirestore.instance.collection('nfc_tags').doc(tagId).set({
            'storeId': widget.storeId,
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

          await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).update({
            'nfcEnabled': true,
            'nfcTagId': tagId,
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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => StoreManagementScreen(storeId: widget.storeId),
                      ),
                          (route) => route.isFirst,
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