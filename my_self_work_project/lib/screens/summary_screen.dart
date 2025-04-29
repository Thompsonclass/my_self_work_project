import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SummaryScreen extends StatelessWidget {
  final GoalModel goalModel;

  SummaryScreen({required this.goalModel});

  void sendGoalToServer(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in.');
      return;
    }

    var url = Uri.parse('http://###.###.#.#:8080/keywords');
    var body = jsonEncode(goalModel.toJson(user.uid));

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('성공'),
            content: const Text('목표가 서버에 저장되었습니다.'),
          ),
        );
      } else {
        print('요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('최종 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('카테고리: ${goalModel.category}'),
            const SizedBox(height: 10),
            Text('유형: ${goalModel.type}'),
            const SizedBox(height: 10),
            Text('기간: ${goalModel.duration}'),
            const SizedBox(height: 10),
            Text('난이도: ${goalModel.difficulty}'),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => sendGoalToServer(context),
                child: const Text('서버로 전송'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
