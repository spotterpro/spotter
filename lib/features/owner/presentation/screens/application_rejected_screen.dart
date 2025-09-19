// ApplicationRejectedScreen.dart - 오타 및 문법 오류 수정 최종본

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// [수정] 'packagepackage:' -> 'package:' 오타 수정
import 'package:spotter/features/owner/presentation/screens/store_application_screen.dart';

class ApplicationRejectedScreen extends StatelessWidget {
  final String applicationId;
  final String rejectionReason;

  const ApplicationRejectedScreen({
    super.key,
    required this.applicationId,
    required this.rejectionReason,
  });

  Future<void> _reapply(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('store_applications')
          .doc(applicationId)
          .delete();

      if (context.mounted) {
        // [수정] StatefulWidget에는 const를 사용할 수 없으므로 제거
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => StoreApplicationScreen()),
        );
      }
    } catch (e) {
      print('Error deleting application: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // build 메서드는 이전과 동일합니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('심사 결과 안내', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              '심사 신청이 반려되었습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300)
              ),
              child: Column(
                children: [
                  const Text(
                    '반려 사유',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rejectionReason,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.5, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            ElevatedButton(
              onPressed: () => _reapply(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('내용 확인 후 다시 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}