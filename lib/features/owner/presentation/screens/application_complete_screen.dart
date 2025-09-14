import 'package:flutter/material.dart';

class ApplicationCompleteScreen extends StatelessWidget {
  const ApplicationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            const Icon(
              Icons.check_circle_outline,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              '심사 신청이 완료되었습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '영업일 기준 2-3일 이내에 심사 결과가 통보됩니다.\n승인 시 입력하신 주소로 NFC 키트가 발송됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const Spacer(flex: 3),
            ElevatedButton(
              onPressed: () {
                // 설정 화면으로 돌아가되, 중간의 신청 화면들은 스택에서 제거
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}