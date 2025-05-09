import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'user_improvement_test.dart';

class SummaryScreen extends StatelessWidget {
  final GoalModel goalModel;

  const SummaryScreen({required this.goalModel, Key? key}) : super(key: key);

  void sendGoalToServer(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final userEmail = user.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 정보를 가져올 수 없습니다.')),
      );
      return;
    }

    goalModel.email = userEmail;

    try {
      await ApiService.postGoal(goalModel.toJsonString());

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('성공'),
          content: Text('목표가 서버에 저장되었습니다.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('최종 확인 (5단계)')),
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
              leading: const Icon(Icons.style),
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
              title: const Text('주당 횟수'),
              subtitle: Text(
                goalModel.sessionsPerWeek != null
                    ? '${goalModel.sessionsPerWeek}회'
                    : '-',
              ),
            ),
            const Divider(),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('서버로 전송'),
              onPressed: () => sendGoalToServer(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('표준 자기계발 UI'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserImprovementScreen(goalModel: goalModel),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
