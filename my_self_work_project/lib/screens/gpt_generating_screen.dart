import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GPTGeneratingScreen extends StatelessWidget {
  final String message;

  const GPTGeneratingScreen({super.key, this.message = '목표를 생성 중입니다...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/ai_generating.json',
              width: 250,
              height: 250,
              repeat: true,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
