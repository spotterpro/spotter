import 'package:flutter/material.dart';

class StoreSwitchScreen extends StatelessWidget {
  const StoreSwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 전환 신청'),
      ),
      body: const Center(
        child: Text('가게 전환 신청 화면'),
      ),
    );
  }
}