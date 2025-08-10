import 'package:flutter/material.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객센터'),
      ),
      body: const Center(
        child: Text('고객센터 화면'),
      ),
    );
  }
}