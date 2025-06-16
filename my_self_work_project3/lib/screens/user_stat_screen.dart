import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_statistics_model.dart';
import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';

class UserStatsScreen extends StatefulWidget {
  const UserStatsScreen({Key? key}) : super(key: key);

  @override
  State<UserStatsScreen> createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends State<UserStatsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.currentUser?.email;
    if (email != null) {
      Provider.of<GoalProvider>(context, listen: false).loadStatistics(email);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '건강':
        return Icons.fitness_center;
      case '생활':
        return Icons.home_rounded;
      case '공부':
        return Icons.menu_book;
      default:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statistics = context.watch<GoalProvider>().statistics;

    if (statistics.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("통계"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        backgroundColor: const Color(0xfff6f9fe),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.blueAccent.withOpacity(0.4)),
              const SizedBox(height: 18),
              const Text(
                "아직 달성한 목표 통계가 없습니다!",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "목표를 완료하면\n여기에서 진행률과 결과를 볼 수 있어요.",
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("통계"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: const Color(0xfff6f9fe),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: statistics.length,
          itemBuilder: (context, index) {
            final stat = statistics[index];
            final sortedDates = stat.sessions.map((s) => s.sessionDate).toList()
              ..sort();
            final startDate = sortedDates.first.toLocal().toString().split(' ')[0];
            final endDate = sortedDates.last.toLocal().toString().split(' ')[0];

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  title: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        width: 38,
                        height: 38,
                        child: Icon(
                          _getCategoryIcon(stat.category),
                          color: Colors.blueAccent,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          "${stat.category} - ${stat.keyword}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: stat.progress,
                          minHeight: 9,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Text(
                              "${(stat.progress * 100).toStringAsFixed(0)}% 완료",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            const SizedBox(width: 16),
                            Text("$startDate ~ $endDate",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  children: _buildSessionList(stat.sessions),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSessionList(List<GoalSessionSummary> sessions) {
    final grouped = <String, List<GoalSessionSummary>>{};
    for (var s in sessions) {
      final date = s.sessionDate.toLocal().toString().split(' ')[0];
      grouped.putIfAbsent(date, () => []).add(s);
    }

    return grouped.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 14, top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
            ),
            ...entry.value.map((s) => Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: s.isCompleted ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(
                  s.isCompleted ? Icons.check_circle : Icons.cancel,
                  color: s.isCompleted ? Colors.green : Colors.red,
                  size: 28,
                ),
                title: Text(
                  s.dailyGoalDetail,
                  style: TextStyle(
                    color: s.isCompleted ? Colors.black87 : Colors.red,
                    fontWeight: s.isCompleted ? FontWeight.normal : FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ))
          ],
        ),
      );
    }).toList();
  }
}
