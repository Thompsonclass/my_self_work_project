import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndividualSummaryScreen extends StatelessWidget {
  final GoalModel goalModel;
  const IndividualSummaryScreen({required this.goalModel, Key? key}) : super(key: key);

  Future<void> sendGoalToServer(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final url = Uri.parse('http://###.###.#.#:8080/keywords');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: goalModel.toJsonString(),
      );
      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('성공'),
            content: Text('목표가 서버에 저장되었습니다.'),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Scaffold(
      appBar: AppBar(title: const Text('최종 확인 (6단계)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('카테고리'),
              subtitle: Text(goalModel.category ?? '-'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('키워드'),
              subtitle: Text(goalModel.keyword ?? '-'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('기간'),
              subtitle: Text(goalModel.period ?? '-'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('주간 스케줄'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${goalModel.sessionsPerWeek ?? 0}회/주'),
                  const SizedBox(height: 4),
                  goalModel.selectedWeekdays != null && goalModel.selectedWeekdays!.isNotEmpty
                      ? Wrap(
                    spacing: 6,
                    children: goalModel.selectedWeekdays!
                        .map((i) => Chip(label: Text(weekdayLabels[i])))
                        .toList(),
                  )
                      : const Text('-'),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('서버로 전송'),
                onPressed: () => sendGoalToServer(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
