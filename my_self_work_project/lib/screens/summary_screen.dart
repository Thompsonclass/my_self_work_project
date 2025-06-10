import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  void sendGoalToServerAndNavigate() async {
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
        // 목표 설정이 완료된 시점 목표를 Hive에 저장
        final goalBox = await Hive.openBox<GoalModel>('goals');
        await goalBox.put('currentGoal', widget.goalModel);
        // 성공했으면 바로 다음 화면으로 이동
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const GPTGeneratingScreen(message: '계획를 준비 중입니다...'),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pop(context); // 표준 UI 로딩 닫기
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserImprovementScreen(goalModel: widget.goalModel),
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

            SizedBox( // Flutter -> Spring -> GPT -> Spring -> DB -> Spring -> Flutter
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_mode),
                label: const Text('최종 실행'),
                onPressed: sendGoalToServerAndNavigate,
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
            const SizedBox(height: 12)
          ],
        ),
      ),
    );
  }
}
