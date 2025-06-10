import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'gpt_generating_screen.dart';
import 'user_improvement_test.dart';
import '../constants.dart';

class SummaryScreen extends StatefulWidget {
  final GoalModel goalModel;

  const SummaryScreen({required this.goalModel, Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  void sendGoalToServer() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GPTGeneratingScreen(message: 'GPT가 목표를 정리하고 있습니다...'),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      Navigator.pop(context); // 로딩 화면 닫기
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    widget.goalModel.email = user.email;

    final url = Uri.parse(ApiConstants.finalizeGoal);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: widget.goalModel.toJsonString(),
      );

      if (!mounted) return;
      Navigator.pop(context); // 로딩 화면 닫기

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('성공'),
            content: const Text('목표가 서버에 저장되었습니다.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 로딩 화면 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: $e')),
      );
    }
  }

  Widget _buildSummaryTile(IconData icon, String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goalModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('최종 확인 (5단계)'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryTile(Icons.category, '카테고리', goal.category ?? '-'),
            _buildSummaryTile(Icons.style, '키워드', goal.keyword ?? '-'),
            _buildSummaryTile(Icons.schedule, '기간', goal.period ?? '-'),
            _buildSummaryTile(
              Icons.repeat,
              '주당 횟수',
              goal.sessionsPerWeek != null ? '${goal.sessionsPerWeek}회' : '-',
            ),
            const Spacer(),

            SizedBox( // Flutter -> Spring -> GPT -> Spring -> DB
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('서버로 전송'),
                onPressed: sendGoalToServer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox( // Flutter -> Spring -> DB -> Spring -> Flutter
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('표준 자기계발 UI'),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const GPTGeneratingScreen(message: '표준 UI를 준비 중입니다...'),
                  );

                  await Future.delayed(const Duration(seconds: 2)); // 만약 처리 시간이 있다면

                  if (!mounted) return;
                  Navigator.pop(context); // 로딩 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserImprovementScreen(goalModel: goal),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.blueAccent),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
