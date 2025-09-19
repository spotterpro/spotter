// features/owner/presentation/screens/nfc_activation_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotter/features/owner/presentation/screens/owner_main_screen.dart';

class NfcActivationScreen extends StatefulWidget {
  final String applicationId;
  const NfcActivationScreen({super.key, required this.applicationId});

  @override
  State<NfcActivationScreen> createState() => _NfcActivationScreenState();
}

class _NfcActivationScreenState extends State<NfcActivationScreen> {
  bool _isActivating = false;

  Future<void> _activateStore() async {
    setState(() { _isActivating = true; });

    try {
      // [추가] Firestore 문서의 status를 'approved'에서 'active'로 업데이트합니다.
      await FirebaseFirestore.instance
          .collection('store_applications')
          .doc(widget.applicationId)
          .update({'status': 'active'});

      // TODO: 추후 실제 NFC 태깅 및 검증 로직 추가

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => OwnerMainScreen(storeId: widget.applicationId)),
              (route) => false,
        );
      }
    } catch (e) {
      print("Error activating store: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("활성화 중 오류가 발생했습니다: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isActivating = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC 키트 활성화'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.nfc, color: Colors.orange, size: 100),
              const SizedBox(height: 32),
              const Text(
                "심사가 승인되었습니다!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "배송된 NFC 키트를 수령하신 후,\n아래 버튼을 누르고 가게를 활성화해주세요.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (_isActivating)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _activateStore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('가게 활성화하기 (임시)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
            ],
          ),
        ),
      ),
    );
  }
}