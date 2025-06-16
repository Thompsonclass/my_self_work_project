import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('에러')),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}