import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';

class PlanGroup {
  final DateTime date;
  final List<GoalSession> sessions;
  PlanGroup({required this.date, required this.sessions});
}

class CategoryDetailScreen extends StatelessWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final allSessions = context.watch<GoalProvider>().sessions;

    // 카테고리에 해당하는 모든 세션 가져오기
    final filtered = allSessions.where((s) => s.sessionDay == category).toList();

    // 날짜별로 그룹화
    final Map<String, List<GoalSession>> grouped = {};
    for (var session in filtered) {
      final key = "${session.sessionDate.year}-${session.sessionDate.month.toString().padLeft(2, '0')}-${session.sessionDate.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(key, () => []).add(session);
    }

    final planGroups = grouped.entries.map((entry) {
      final dateParts = entry.key.split('-').map(int.parse).toList();
      final date = DateTime(dateParts[0], dateParts[1], dateParts[2]);
      return PlanGroup(date: date, sessions: entry.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: Text("$category 목표 이력"),
        backgroundColor: Colors.blueAccent,
      ),
      body: planGroups.isEmpty
          ? const Center(child: Text("해당 카테고리의 목표가 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: planGroups.length,
        itemBuilder: (_, idx) {
          final group = planGroups[idx];
          final date = group.date;
          final formattedDate =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ...group.sessions.map(
                    (s) => ListTile(
                  leading: const Icon(Icons.circle, color: Colors.grey),
                  title: Text(s.dailyGoalDetail),
                  subtitle: (s.tip?.isNotEmpty == true) ? Text(s.tip!) : null,
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
