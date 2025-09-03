import 'package:flutter/material.dart';

class OwnerMessagesScreen extends StatelessWidget {
  final String storeId;
  const OwnerMessagesScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // AppBar는 store_owner_main_screen에서 관리하므로 여기엔 별도의 AppBar가 필요 없습니다.
    return const Scaffold(
      body: Center(
        // TODO: storeId를 사용하여 해당 가게에 온 메시지 목록을 Firestore에서 불러와야 합니다.
        child: Text('사장님 메시지 기능 준비중입니다.'),
      ),
    );
  }
}