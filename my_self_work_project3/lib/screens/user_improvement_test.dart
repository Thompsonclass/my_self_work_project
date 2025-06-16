import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../services/api_service.dart';
import '../services/goal_storage_service.dart';
import 'ErrorScreen.dart';
import 'package:hive/hive.dart';

class PlanGroup {
  final DateTime date;
  final List<GoalSession> sessions;
  PlanGroup({required this.date, required this.sessions});
}

class UserImprovementScreen extends StatefulWidget {
  const UserImprovementScreen({Key? key}) : super(key: key);

  @override
  _UserImprovementScreenState createState() => _UserImprovementScreenState();
}

class _UserImprovementScreenState extends State<UserImprovementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<GoalSession> _dailyTasks = [];
  List<PlanGroup> _fullPlan = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final goal = context.read<GoalProvider>().goal;
    final email = goal?.email;
    if (email == null) return;

    try {
      final sessions = await ApiService.fetchSessions(email);
      final today = DateTime.now();
      final grouped = <DateTime, List<GoalSession>>{};

      for (var s in sessions) {
        final date = s.sessionDate;
        grouped.putIfAbsent(date, () => []).add(s);
      }

      _fullPlan = grouped.entries
          .map((e) => PlanGroup(date: e.key, sessions: e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final todayGroup = _fullPlan.firstWhere(
            (g) => isSameDay(g.date, today),
        orElse: () => PlanGroup(date: today, sessions: []),
      );

      setState(() {
        _dailyTasks = todayGroup.sessions;
      });
    } catch (e) {
      debugPrint('목표 로딩 실패: $e');
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double _calculateOverallProgress() {
    final allSessions = _fullPlan.expand((g) => g.sessions).toList();
    final completedCount = allSessions.where((s) => s.isComplete).length;
    return allSessions.isEmpty ? 0.0 : completedCount / allSessions.length;
  }

  Widget _buildProgressBar(double progress) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("전체 진행률", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    color: Colors.blueAccent,
                    minHeight: 24,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<GoalProvider>().goal;
    if (goal == null) return const ErrorScreen(message: "목표 정보 없음");

    final progress = _calculateOverallProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text("실천 목표"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          _buildProgressBar(progress),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent, // 선택된 탭 텍스트
            unselectedLabelColor: Colors.grey, // 선택되지 않은 탭 텍스트
            indicatorColor: Colors.blueAccent, // 아래 강조선
            indicatorWeight: 3.3, // 아래선 두께(더 두껍게)
            indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
            tabs: const [
              Tab(text: '일일 목표'),
              Tab(text: '전체 목표'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSessionList(_dailyTasks),
                _buildFullPlanList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<GoalSession> sessions) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (sessions.isEmpty) {
      return const Center(child: Text("오늘 할 목표가 없습니다."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length + 1,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, idx) {
        if (idx == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              todayStr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }
        final s = sessions[idx - 1];
        return _buildSessionTile(s);
      },
    );
  }

  Widget _buildFullPlanList() {
    if (_fullPlan.isEmpty) {
      return const Center(child: Text("계획된 목표가 없습니다."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
            ...group.sessions.map((s) => _buildSessionTile(s)),
            const Divider(),
          ],
        );
      },
    );
  }

  // ---------- 🟦 애니메이션 롱프레스 카드 위젯 ----------
  Widget _buildSessionTile(GoalSession s) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime sessionDay = DateTime(s.sessionDate.year, s.sessionDate.month, s.sessionDate.day);

    final bool isPast = sessionDay.isBefore(today);

    final Color bgColor = s.isComplete
        ? Colors.green.shade50
        : isPast
        ? Colors.red.shade50
        : Colors.white;

    IconData iconData;
    Color iconColor;

    if (s.isComplete) {
      iconData = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isPast) {
      iconData = Icons.cancel;
      iconColor = Colors.red;
    } else {
      iconData = Icons.radio_button_unchecked;
      iconColor = Colors.blueAccent;
    }

    return AnimatedSessionTile(
      session: s,
      isPast: isPast,
      bgColor: bgColor,
      iconData: iconData,
      iconColor: iconColor,
      onComplete: (isChecked) => _updateSessionIsComplete(s, isChecked),
      onEdit: (updatedDetail, updatedTip) async {
        try {
          await ApiService.updateSession({
            "id": s.id,
            "dailyGoalDetail": updatedDetail,
            "tip": updatedTip,
            "isComplete": s.isComplete,
          });

          setState(() {
            s.dailyGoalDetail = updatedDetail;
            s.tip = updatedTip;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("수정 실패: $e")));
        }
      },
    );
  }

  void _updateSessionIsComplete(GoalSession session, bool? value) async {
    final isChecked = value ?? false;

    try {
      await ApiService.updateSession({
        "id": session.id,
        "isComplete": isChecked,
        "dailyGoalDetail": session.dailyGoalDetail,
        "tip": session.tip ?? "",
      });

      setState(() {
        session.isComplete = isChecked;
      });
    } catch (e) {
      debugPrint("isComplete 업데이트 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("체크 상태 업데이트 실패: $e")),
      );
    }
  }
}

// 🟦 롱프레스 애니메이션 카드 위젯
class AnimatedSessionTile extends StatefulWidget {
  final GoalSession session;
  final bool isPast;
  final Function(bool?) onComplete;
  final Function(String, String) onEdit;
  final Color bgColor;
  final IconData iconData;
  final Color iconColor;

  const AnimatedSessionTile({
    Key? key,
    required this.session,
    required this.isPast,
    required this.onComplete,
    required this.onEdit,
    required this.bgColor,
    required this.iconData,
    required this.iconColor,
  }) : super(key: key);

  @override
  State<AnimatedSessionTile> createState() => _AnimatedSessionTileState();
}

class _AnimatedSessionTileState extends State<AnimatedSessionTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;
  Timer? _holdTimer;
  DateTime? _holdStart;
  static const holdDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 120),
      lowerBound: 1.0,
      upperBound: 1.04,
      value: 1.0,
    );
    _controller.addListener(() {
      setState(() {
        _scale = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('3초 이상 길게 누르면 수정할 수 있습니다.'),
          duration: holdDuration,
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    _controller.forward();
    _holdStart = DateTime.now();
    _holdTimer = Timer(holdDuration, () {});
  }

  void _onLongPressEnd(LongPressEndDetails details) async {
    _controller.reverse();
    final now = DateTime.now();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    _holdTimer?.cancel();

    if (_holdStart != null && now.difference(_holdStart!) >= holdDuration) {
      HapticFeedback.lightImpact();
      await Future.delayed(Duration(milliseconds: 80));
      _showEditDialog();
    }
    _holdStart = null;
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: widget.session.dailyGoalDetail);
    final tipController = TextEditingController(text: widget.session.tip ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('목표 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: '목표 내용')),
            TextField(controller: tipController, decoration: const InputDecoration(labelText: '팁')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final updatedDetail = titleController.text;
              final updatedTip = tipController.text;
              widget.onEdit(updatedDetail, updatedTip);
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          color: widget.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          shadowColor: Colors.blueAccent.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 체크 아이콘/버튼 더 크게
                Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => widget.onComplete(!s.isComplete),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: s.isComplete
                                ? Colors.green.withOpacity(0.09)
                                : widget.isPast
                                ? Colors.red.withOpacity(0.09)
                                : Colors.blueAccent.withOpacity(0.04),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.iconData,
                            color: widget.iconColor,
                            size: 29,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 17),
                // 세부 목표/팁
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.dailyGoalDetail,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: s.isComplete
                              ? Colors.green
                              : widget.isPast
                              ? Colors.red
                              : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      if (s.tip?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            s.tip!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
