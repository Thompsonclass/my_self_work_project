import 'package:flutter/material.dart';
import '/screens/user_setting_screen.dart'; // 설정
import '/screens/user_stat_screen.dart'; // 통계
import '/screens/user_improvement_test.dart'; // 홈
import '/screens/category_detail_screen.dart'; // ⬅️ 새로 추가: 카테고리별 세부 목표 화면

class UserStatsScreen extends StatelessWidget {
  const UserStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const int _selectedBottomIndex = 2;

    // 추후 Firebase 연동 시 이 부분을 FutureBuilder 등으로 대체
    final List<GoalSummary> completedGoals = [
      GoalSummary(category: "건강", progress: 0.8),
      GoalSummary(category: "공부", progress: 0.6),
      GoalSummary(category: "독서", progress: 1.0),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("통계"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  goal.category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 4),
                    Text("${(goal.progress * 100).toStringAsFixed(0)}% 완료"),
                  ],
                ),
                // ✅ 눌렀을 때 세부 목표 화면으로 이동
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(category: goal.category),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          if (index == _selectedBottomIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/improvement');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/setting');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/stat');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
        ],
      ),
    );
  }
}

class GoalSummary {
  final String category;
  final double progress;

  GoalSummary({required this.category, required this.progress});
}
