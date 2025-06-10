import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/goal_model.dart';

enum TaskStatus { pending, done, ignored }
//[
//   {
//     "date": "2025-05-09",
//     "tasks": ["헬스장 1시간", "스트레칭 10분"]
//   },
//   {
//     "date": "2025-05-11",
//     "tasks": ["요가 30분"]
//   }
// ]
class Task {
  final String title;
  TaskStatus status;

  Task({required this.title, this.status = TaskStatus.pending});

  factory Task.fromJson(String title) => Task(title: title);
}

class PlanGroup {
  final DateTime date;
  final List<Task> tasks;

  PlanGroup({required this.date, required this.tasks});

  factory PlanGroup.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    final tasks = (json['tasks'] as List).map((t) => Task.fromJson(t)).toList();
    return PlanGroup(date: date, tasks: tasks);
  }
}

class UserImprovementScreen extends StatefulWidget {
  final GoalModel goalModel;

  const UserImprovementScreen({Key? key, required this.goalModel}) : super(key: key);

  @override
  State<UserImprovementScreen> createState() => _UserImprovementScreenState();
}

class _UserImprovementScreenState extends State<UserImprovementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<PlanGroup> _fullPlan = [];
  List<Task> _dailyTasks = [];
  double _todayProgress = 0;
  double _overallProgress = 0;

  Duration? _initialDuration;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  final TextEditingController _minutesController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchGPTPlan();
  }

  Future<void> _fetchGPTPlan() async {
    try {
      final url = Uri.parse('http://###.###.#.#:8080/api/generate-plan'); // 서버 주소 수정 필요
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"goalId": widget.goalModel.id}), // goalId 필요
      );

      if (response.statusCode == 200) {
        final jsonPlan = jsonDecode(response.body);
        _applyPlanFromJson(jsonPlan);
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('계획 불러오기 실패: $e')));
    }
  }

  void _applyPlanFromJson(List<dynamic> jsonPlan) {
    _fullPlan = jsonPlan.map((e) => PlanGroup.fromJson(e)).toList();
    _fullPlan.sort((a, b) => a.date.compareTo(b.date));

    final today = DateTime.now();
    final todayGroup = _fullPlan.firstWhere(
          (g) => g.date.year == today.year &&
          g.date.month == today.month &&
          g.date.day == today.day,
      orElse: () => PlanGroup(date: today, tasks: []),
    );

    _dailyTasks = todayGroup.tasks;
    _calculateProgress();
  }

  void _calculateProgress() {
    final todayDone = _dailyTasks.where((t) => t.status == TaskStatus.done).length;
    _todayProgress = _dailyTasks.isNotEmpty ? todayDone / _dailyTasks.length : 0;

    final allTasks = _fullPlan.expand((g) => g.tasks).toList();
    final totalDone = allTasks.where((t) => t.status == TaskStatus.done).length;
    _overallProgress = allTasks.isNotEmpty ? totalDone / allTasks.length : 0;

    setState(() {});
  }

  void _onTaskAction(Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task.title),
        content: const Text('상태를 선택하세요'),
        actions: [
          TextButton(onPressed: () => _updateTask(task, TaskStatus.done), child: const Text('완료')),
          TextButton(onPressed: () => _updateTask(task, TaskStatus.ignored), child: const Text('실패')),
        ],
      ),
    );
  }

  void _updateTask(Task task, TaskStatus status) {
    setState(() {
      task.status = status;
      _calculateProgress();
    });
    Navigator.pop(context);
  }

  void _showTimerSettingDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('타이머 설정 (분)'),
        content: TextField(
          controller: _minutesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '분', hintText: '예: 10'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(_minutesController.text) ?? 10;
              setState(() => _initialDuration = Duration(minutes: minutes));
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    if (_initialDuration == null) _initialDuration = const Duration(minutes: 10);
    _timer?.cancel();
    setState(() => _remaining = _initialDuration!);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _remaining = Duration.zero);
  }

  String get _timeString {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

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
        title: const Text('개선 계획 보기'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _showTimerSettingDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '일일'), Tab(text: '전체')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('오늘 진행률'),
                LinearProgressIndicator(value: _todayProgress),
                Text('${(_todayProgress * 100).round()}%'),
                const SizedBox(height: 8),
                Text('전체 진행률'),
                LinearProgressIndicator(value: _overallProgress),
                Text('${(_overallProgress * 100).round()}%'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('타이머: $_timeString', style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    ElevatedButton(onPressed: _startTimer, child: const Text('시작')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _stopTimer, child: const Text('중지')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_dailyTasks),
                _buildAllPlanList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) return const Center(child: Text('오늘 할 일이 없습니다.'));
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (_, i) {
        final task = tasks[i];
        return ListTile(
          leading: Icon(_statusIcon(task.status), color: _statusColor(task.status)),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
              color: task.status == TaskStatus.ignored ? Colors.red : null,
            ),
          ),
          onTap: () => _onTaskAction(task),
        );
      },
    );
  }

  Widget _buildAllPlanList() {
    if (_fullPlan.isEmpty) return const Center(child: Text('계획이 없습니다.'));
    return ListView.builder(
      itemCount: _fullPlan.length,
      itemBuilder: (_, i) {
        final group = _fullPlan[i];
        final formattedDate = '${group.date.year}-${group.date.month.toString().padLeft(2, '0')}-${group.date.day.toString().padLeft(2, '0')}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...group.tasks.map((task) => ListTile(
              leading: Icon(_statusIcon(task.status), color: _statusColor(task.status)),
              title: Text(task.title),
              onTap: () => _onTaskAction(task),
            )),
            const Divider(),
          ],
        );
      },
    );
  }
}
