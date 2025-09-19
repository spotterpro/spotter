// features/owner/presentation/screens/owner_mode_router_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'application_pending_screen.dart';
import 'application_rejected_screen.dart';
import 'store_application_screen.dart';
import 'nfc_activation_screen.dart';
import 'owner_main_screen.dart'; // [추가]

class OwnerModeRouterScreen extends StatelessWidget {
  const OwnerModeRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("로그인이 필요합니다.")));
    }

    final query = FirebaseFirestore.instance.collection('store_applications').where('ownerId', isEqualTo: user.uid).limit(1);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("오류가 발생했습니다: ${snapshot.error}")));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const StoreApplicationScreen();
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? '';

        switch (status) {
          case 'pending':
            return const ApplicationPendingScreen();
          case 'rejected':
            final reason = data['rejectionReason'] ?? '사유 없음';
            return ApplicationRejectedScreen(applicationId: doc.id, rejectionReason: reason);
          case 'approved':
            return NfcActivationScreen(applicationId: doc.id);
        // [추가] 'active' 상태일 경우, 즉시 가게 메인 화면으로 보냅니다.
          case 'active':
            return OwnerMainScreen(storeId: doc.id);
          default:
            return const StoreApplicationScreen();
        }
      },
    );
  }
}