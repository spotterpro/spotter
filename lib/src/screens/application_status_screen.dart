// 📁 lib/src/screens/application_status_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/src/screens/store_switch_screen.dart';

class ApplicationStatusScreen extends StatefulWidget {
  final String status;

  const ApplicationStatusScreen({
    super.key,
    required this.status,
  });

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  // --- 🔥🔥🔥 데이터를 실시간으로 가져오기 위해 StatefulWidget으로 변경 ---
  Stream<DocumentSnapshot>? _storeStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _storeStream = FirebaseFirestore.instance.collection('stores').doc(user.uid).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '뒤로가기',
        ),
        title: const Text('신청 현황'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _storeStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              // 문서가 삭제되었거나 없는 경우, 이전 상태를 기반으로 표시
              return _buildStatusViewByString(widget.status);
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final status = data['status'] ?? widget.status;
            final rejectionReason = data['rejectionReason'] as String?;

            return _buildStatusViewByString(status, rejectionReason: rejectionReason);
          },
        ),
      ),
    );
  }

  // --- 🔥🔥🔥 상태와 반려사유에 따라 위젯을 생성하는 로직 분리 ---
  Widget _buildStatusViewByString(String status, {String? rejectionReason}) {
    switch (status) {
      case 'pending':
        return _buildStatusView(
          icon: Icons.hourglass_empty_rounded,
          iconColor: Colors.orange,
          title: '심사가 진행 중입니다.',
          message: '사장님의 소중한 가게 정보를 확인하고 있어요. 심사가 완료되면 바로 알려드릴게요!',
          subMessage: '실제 앱에서는 영업일 기준 1-2일이 소요됩니다.',
        );
      case 'rejected':
        return _buildStatusView(
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red,
          title: '심사 요청이 반려되었습니다.',
          message: rejectionReason != null && rejectionReason.isNotEmpty
              ? '반려 사유:\n"$rejectionReason"'
              : '아쉽지만, 일부 정보가 명확하지 않아 심사가 반려되었어요.',
          button: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const StoreSwitchScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('정보 수정 후 다시 신청하기'),
          ),
        );
      default:
      // approved, awaiting_nfc 등의 상태는 라우터에서 다른 화면으로 보내므로
      // 이 화면에서는 기본적으로 보이지 않아야 합니다.
        return _buildStatusView(
          icon: Icons.help_outline,
          iconColor: Colors.grey,
          title: '알 수 없는 상태입니다.',
          message: '고객센터로 문의해주세요.',
        );
    }
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