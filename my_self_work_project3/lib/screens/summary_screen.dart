import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../providers/goal_provider.dart';
import '../services/api_service.dart';
import '../services/goal_storage_service.dart';
import 'gpt_generating_screen.dart';
import 'improvement_shell.dart';
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
      Navigator.pop(context);
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
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final goalBox = await Hive.openBox<GoalModel>('goals');
        await goalBox.put('currentGoal', widget.goalModel);

        Provider.of<GoalProvider>(context, listen: false).setGoal(widget.goalModel);

        try {
          final decoded = jsonDecode(response.body);
          if (decoded['id'] == null) {
            throw Exception("Goal ID를 파싱할 수 없습니다: ${response.body}");
          }

          final goalId = decoded['id'].toString();
          final rawSessions = await ApiService.fetchTodaySessions(user.email!);

          final sessions = rawSessions.map((e) => GoalSession(
            id: e['id'],
            sessionDay: e['sessionDay'] ?? '',
            dailyGoalDetail: e['title'],
            tip: e['tip'] ?? '',
            isComplete: e['isCompleted'] ?? false,
            sessionDate: DateTime.parse(e['date']),
          )).toList();

          await GoalStorageService().saveSessions(sessions);
          Provider.of<GoalProvider>(context, listen: false).sessions = sessions;

        } catch (e) {
          debugPrint("GoalSession 저장 중 오류 발생: $e");
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const GPTGeneratingScreen(message: '계획을 준비 중입니다...'),
        );

        await Future.delayed(const Duration(seconds: 10));
        if (!mounted) return;
        Navigator.pop(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ImprovementShell(),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = '인터넷 연결이 불안정해요. 와이파이나 데이터를 확인해주세요.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = '로그인 인증이 만료됐어요. 다시 로그인해 주세요.';
      } else {
        errorMessage = '예상치 못한 오류가 발생했어요. 잠시 후 다시 시도해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Widget _buildSummaryTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.14), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.07),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 28),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueAccent),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goalModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('최종 확인'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: const Color(0xfff6f9fe),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 14),
            _buildSummaryTile(Icons.category, '카테고리', goal.category ?? '-'),
            _buildSummaryTile(Icons.style, '키워드', goal.keyword ?? '-'),
            _buildSummaryTile(Icons.schedule, '기간', goal.period ?? '-'),
            _buildSummaryTile(
              Icons.repeat,
              '주당 횟수',
              goal.sessionsPerWeek != null ? '${goal.sessionsPerWeek}회' : '-',
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_mode, size: 27),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 7),
                  child: Text('최종 실행', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                onPressed: sendGoalToServerAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 18)
          ],
        ),
      ),
    );
  }
}
