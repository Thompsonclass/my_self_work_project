import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '/screens/user_improvement_test.dart'; // Task, TaskStatus 재사용

class PlanGroup {
  final DateTime date;
  final List<Task> tasks;
  PlanGroup({required this.date, required this.tasks});
}

class CategoryDetailScreen extends StatefulWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final List<PlanGroup> _completedPlans = [
    PlanGroup(
      date: DateTime(2025, 5, 1),
      tasks: [
        Task(title: "아침 스트레칭", tip: "5분만 해도 좋아요", status: TaskStatus.done),
        Task(title: "물 1L 마시기", tip: "자주 마시기", status: TaskStatus.ignored),
      ],
    ),
    PlanGroup(
      date: DateTime(2025, 5, 2),
      tasks: [
        Task(title: "저녁 걷기", tip: "하루 20분", status: TaskStatus.done),
      ],
    ),
  ];

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.ignored:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return Icons.check_circle;
      case TaskStatus.ignored:
        return Icons.block;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} 목표 이력"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _completedPlans.isEmpty
          ? const Center(child: Text("완료된 목표가 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedPlans.length,
        itemBuilder: (_, idx) {
          final group = _completedPlans[idx];
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
              ...group.tasks.map(
                    (t) => ListTile(
                  leading: Icon(_statusIcon(t.status), color: _statusColor(t.status)),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                      color: t.status == TaskStatus.ignored ? Colors.red : null,
                    ),
                  ),
                  subtitle: t.tip.isNotEmpty ? Text(t.tip) : null,
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
