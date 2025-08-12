// 📁 lib/src/screens/application_status_screen.dart

import 'package:flutter/material.dart';
import 'package:spotter/src/screens/store_switch_screen.dart'; // 추가된 부분

class ApplicationStatusScreen extends StatelessWidget {
  final String status;

  const ApplicationStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Widget statusWidget;

    switch (status) {
      case 'pending':
        statusWidget = _buildStatusView(
          icon: Icons.hourglass_empty_rounded,
          iconColor: Colors.orange,
          title: '심사가 진행 중입니다.',
          message: '사장님의 소중한 가게 정보를 꼼꼼히 확인하고 있어요.\n심사가 완료되면 바로 알려드릴게요!',
          subMessage: '실제 앱에서는 영업일 기준 1-2일이 소요됩니다.',
        );
        break;
      case 'approved':
        statusWidget = _buildStatusView(
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.green,
          title: '심사가 완료되었습니다!',
          message: '이제 사장님의 가게에 NFC 스티커를 등록하고\n손님들을 위한 스탬프 투어를 만들어보세요!',
          button: ElevatedButton.icon(
            onPressed: () {
              // TODO: NFC 등록 화면으로 이동
            },
            icon: const Icon(Icons.nfc_rounded),
            label: const Text('NFC 스티커 등록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );
        break;
      case 'rejected':
        statusWidget = _buildStatusView(
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
          title: '심사 요청이 반려되었습니다.',
          message: '아쉽지만, 일부 정보가 명확하지 않아 심사가 반려되었어요.\n정보를 수정하여 다시 신청해주세요.',
          // --- 형님의 요청대로 수정된 부분 ---
          button: ElevatedButton(
            onPressed: () {
              // 반려 화면을 닫고, 신청서 작성 화면으로 새로 이동합니다.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const StoreSwitchScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('다시 신청하기'),
          ),
        );
        break;
      default:
        statusWidget = const Center(child: Text('알 수 없는 상태입니다.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('신청 현황'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: statusWidget,
      ),
    );
  }

  Widget _buildStatusView({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    String? subMessage,
    Widget? button,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (button != null) button,
          if (subMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                subMessage,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}