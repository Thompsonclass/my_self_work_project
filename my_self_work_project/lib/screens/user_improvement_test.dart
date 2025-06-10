import 'dart:async';
import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/api_service.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../services/goal_storage_service.dart';

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

  List<Task> _dailyTasks = [];
  List<PlanGroup> _fullPlan = [];

  Duration? _initialDuration;
  Duration _remaining = Duration.zero;
  Timer? _timer;

  final TextEditingController _minutesController = TextEditingController(text: '10');
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();

    // 목표 저장
    saveGoalToHive(widget.goalModel);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> saveGoalToHive(GoalModel goal) async {
    final box = await Hive.openBox<GoalModel>('goals');
    await box.put('currentGoal', goal);
  }

  Future<void> _initData() async {
    final email = widget.goalModel.email;
    if (email == null) return;

    final rawSessions = await ApiService.fetchSessions(email);
    final today = DateTime.now();

    final grouped = <DateTime, List<Task>>{};
    for (var s in rawSessions) {
      final date = DateTime.parse(s['date']).toLocal();
      final task = Task(title: s['title'], tip: s['tip'] ?? '');
      grouped.putIfAbsent(date, () => []).add(task);
    }

    _fullPlan = grouped.entries
        .map((e) => PlanGroup(date: e.key, tasks: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final todayGroup = _fullPlan.firstWhere(
          (g) => isSameDay(g.date, today),
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

  // 3. 목표 편집 다이얼로그 추가
  void _showEditDialog(Task task) async {
    final titleController = TextEditingController(text: task.title);
    final tipController = TextEditingController(text: task.tip);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('목표 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '목표'),
            ),
            TextField(
              controller: tipController,
              decoration: const InputDecoration(labelText: '세부사항'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                task.title = titleController.text;
                task.tip = tipController.text;
              });
              await GoalStorageService().saveTasks(_fullPlan.expand((g) => g.tasks).toList());
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
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

    return WillPopScope(
      onWillPop: () async => false, //안드로이드 뒤로가기 버튼 막기
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //뒤로가기 아이콘 제거
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
                        onPressed: () => _showEditDialog(task),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                          color: task.status == TaskStatus.ignored ? Colors.red : null,
                        ),
                      ),
                      subtitle: task.tip.isNotEmpty ? Text(task.tip) : null,
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
                          subtitle: t.tip.isNotEmpty ? Text(t.tip) : null,
                          onTap: () => _showEditDialog(t),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          if (index == _selectedBottomIndex) return;

          setState(() {
            _selectedBottomIndex = index;
          });

          // 경로 기반으로 화면 전환
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
      ),
    );
  }
}
