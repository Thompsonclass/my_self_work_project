import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'user_improvement_test.dart';

class SummaryScreen extends StatelessWidget {
  final GoalModel goalModel;

  const SummaryScreen({required this.goalModel, Key? key}) : super(key: key);

  void sendGoalToServer(BuildContext context) async {
    // 현재 로그인한 Firebase 사용자 가져오기
    final user = FirebaseAuth.instance.currentUser;
    // 로그인이 되어 있지 않으면 경고 메시지 표시
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }
    // 사용자 이메일 추출 (Spring 서버에서 사용자 식별에 사용)
    final userEmail = user.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 정보를 가져올 수 없습니다.')),
      );
      return;
    }
    // 목표 모델 객체에 이메일 설정 → 서버에 함께 전송될 수 있도록
    goalModel.email = userEmail;

    try {
      // API 서비스로 목표 데이터를 JSON 형식으로 전송
      // goalModel.toJsonString()은 아래와 같은 JSON을 반환함:
      // {
      //   "email": "사용자 이메일",
      //   "category": "운동",
      //   "keyword": "헬스",
      //   "period": "4주",
      //   "includeWeekend": true,
      //   "selectedWeekdays": ["월", "수", "금"],
      //   "sessionsPerWeek": 3
      // }
      await ApiService.postGoal(goalModel.toJsonString());

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('성공'),
          content: Text('목표가 서버에 저장되었습니다.'),
        ),
      );
    } catch (e) {
      // 네트워크 오류 또는 서버 오류 발생 시 메시지 표시
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
