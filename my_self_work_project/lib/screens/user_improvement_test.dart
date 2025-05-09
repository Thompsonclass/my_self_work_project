import 'dart:async';
import 'package:flutter/material.dart';
import '../models/goal_model.dart';

enum TaskStatus { pending, done, ignored }

class Task {
  final String title;
  TaskStatus status;
  Task({required this.title, this.status = TaskStatus.pending});
}

class PlanGroup {
  final DateTime date;
  final List<Task> tasks;
  PlanGroup({required this.date, required this.tasks});
}

class UserImprovementScreen extends StatefulWidget {
  final GoalModel goalModel;
  const UserImprovementScreen({Key? key, required this.goalModel}) : super(key: key);

  @override
  _UserImprovementScreenState createState() => _UserImprovementScreenState();
}

class _UserImprovementScreenState extends State<UserImprovementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  double _todayProgress = 0;
  double _overallProgress = 0;

  late List<Task> _dailyTasks;
  late List<PlanGroup> _fullPlan;

  Duration? _initialDuration;
  Duration _remaining = Duration.zero;
  Timer? _timer;

  final TextEditingController _minutesController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  int _durationInDays(String? duration) {
    switch (duration) {
      case '2주일':
        return 14;
      case '한 달':
        return 30;
      case '1주일':
      default:
        return 7;
    }
  }

  int toUserWeekday(int dartWeekday) {
    return dartWeekday - 1; // 1(월) → 0, 2(화) → 1, ..., 7(일) → 6
  }

  void _initData() {
    final goal = widget.goalModel;
    final today = DateTime.now();
    final String taskTitle = goal.keyword != null ? '오늘의 ${goal.keyword!}' : '자기계발 태스크';
    final selectedDays = goal.selectedWeekdays ?? [];
    final weeklyCount = goal.sessionsPerWeek ?? 1;
    final totalDays = _durationInDays(goal.period);
    final totalWeeks = (totalDays / 7).ceil();

    _fullPlan = [];

    for (int week = 0; week < totalWeeks; week++) {
      final weekStart = today.add(Duration(days: week * 7));

      final base = weeklyCount ~/ selectedDays.length;
      final extra = weeklyCount % selectedDays.length;

      for (int i = 0; i < selectedDays.length; i++) {
        final userWeekday = selectedDays[i];

        // 각 주의 시작일 기준으로 해당 요일 날짜 계산
        DateTime targetDate = weekStart;
        while (toUserWeekday(targetDate.weekday) != userWeekday) {
          targetDate = targetDate.add(const Duration(days: 1));
        }

        if (targetDate.difference(today).inDays >= totalDays) continue;

        final taskCount = base + (i < extra ? 1 : 0);
        _fullPlan.add(
          PlanGroup(
            date: targetDate,
            tasks: List.generate(taskCount, (_) => Task(title: taskTitle)),
          ),
        );
      }
    }

    _fullPlan.sort((a, b) => a.date.compareTo(b.date));

    final todayGroup = _fullPlan.firstWhere(
          (g) =>
      g.date.year == today.year &&
          g.date.month == today.month &&
          g.date.day == today.day,
      orElse: () => PlanGroup(date: today, tasks: []),
    );

    _dailyTasks = todayGroup.tasks;
    _calculateProgress();
  }

  void _calculateProgress() {
    final todayTotal = _dailyTasks.length;
    final todayDone = _dailyTasks.where((t) => t.status == TaskStatus.done).length;
    _todayProgress = todayTotal > 0 ? todayDone / todayTotal : 0;

    final allTasks = _fullPlan.expand((g) => g.tasks).toList();
    final doneTasks = allTasks.where((t) => t.status == TaskStatus.done).length;
    _overallProgress = allTasks.isNotEmpty ? doneTasks / allTasks.length : 0;

    setState(() {});
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
              final minutes = int.tryParse(_minutesController.text) ?? 0;
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
    if (_initialDuration == null) {
      _initialDuration = Duration(minutes: 10);
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final tabBarWidth = screenWidth * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: tabBarWidth,
          child: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: '일일'), Tab(text: '전체')],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.timer), tooltip: '타이머 설정', onPressed: _showTimerSettingDialog),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Text('오늘 진행률'),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(value: _todayProgress, backgroundColor: Colors.transparent, minHeight: 20),
                      ),
                    ),
                    Text('${(_todayProgress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('전체 진행률'),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(value: _overallProgress, backgroundColor: Colors.transparent, minHeight: 20),
                      ),
                    ),
                    Text('${(_overallProgress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('타이머: $_timeString', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dailyTasks.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, idx) {
                    final task = _dailyTasks[idx];
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(_statusIcon(task.status), color: _statusColor(task.status)),
                        onPressed: () => _onTaskAction(task),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                          color: task.status == TaskStatus.ignored ? Colors.red : null,
                        ),
                      ),
                    );
                  },
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _fullPlan.length,
                  itemBuilder: (_, idx) {
                    final group = _fullPlan[idx];
                    final date = group.date;
                    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(formattedDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        ...group.tasks.map((t) => ListTile(
                          leading: Icon(_statusIcon(t.status), color: _statusColor(t.status)),
                          title: Text(
                            t.title,
                            style: TextStyle(decoration: t.status == TaskStatus.done ? TextDecoration.lineThrough : null),
                          ),
                          onTap: () => _onTaskAction(t),
                        )),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
