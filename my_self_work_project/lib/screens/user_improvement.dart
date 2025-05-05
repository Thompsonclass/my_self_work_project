// lib/screens/standard_plan_screen.dart
import 'package:flutter/material.dart';

class StandardPlanScreen extends StatefulWidget {
  /// 서버에서 받아올 JSON 데이터를 그대로 넣어주세요.
  /// 형식:
  /// {
  ///   "tabs": [ {"id":"daily","label":"일일"}, {"id":"overall","label":"전체"} ],
  ///   "period": {
  ///     "startDate":"2025-05-01","endDate":"2025-05-31",
  ///     "progressPercent":0.5
  ///   },
  ///   "dailyTasks":[
  ///     {"id":"t1","title":"3시간 독서하기","status":"pending"},
  ///     {"id":"t2","title":"아침 스트레칭","status":"ignored"}
  ///   ],
  ///   "fullPlan":[
  ///     {
  ///       "date":"2025-05-01",
  ///       "tasks":[
  ///         {"id":"t1","title":"3시간 독서하기","status":"done"},
  ///         {"id":"t2","title":"저녁 산책","status":"pending"}
  ///       ]
  ///     },
  ///     // ...
  ///   ]
  /// }
  final Map<String, dynamic>? data;
  const StandardPlanScreen({Key? key, this.data}) : super(key: key);

  @override
  _StandardPlanScreenState createState() => _StandardPlanScreenState();
}

class _StandardPlanScreenState extends State<StandardPlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<TabInfo> _tabs;
  late final double _progress;
  late final List<Task> _dailyTasks;
  late final List<PlanGroup> _fullPlan;

  Map<String, dynamic> get _sample => {
    "tabs": [
      {"id": "daily", "label": "일일"},
      {"id": "overall", "label": "전체"},
    ],
    "period": {
      "startDate": "2025-05-01",
      "endDate": "2025-05-31",
      "progressPercent": 0.4
    },
    "dailyTasks": [
      {"id": "t1", "title": "3시간 독서하기", "status": "pending"},
      {"id": "t2", "title": "아침 스트레칭 10분", "status": "ignored"},
      {"id": "t3", "title": "저녁 산책 30분", "status": "done"},
    ],
    "fullPlan": [
      {
        "date": "2025-05-01",
        "tasks": [
          {"id": "t1", "title": "3시간 독서하기", "status": "done"},
          {"id": "t2", "title": "저녁 산책", "status": "pending"},
        ]
      },
      {
        "date": "2025-05-02",
        "tasks": [
          {"id": "t3", "title": "아침 스트레칭", "status": "ignored"},
        ]
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    final json = widget.data ?? _sample;

    // Tabs
    _tabs = (json['tabs'] as List<dynamic>? ?? [])
        .map((e) => TabInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    // Progress
    _progress = ((json['period'] as Map<String, dynamic>?)?['progressPercent']
    as num? ??
        _sample['period']['progressPercent'])
        .toDouble();

    // Daily tasks
    _dailyTasks = (json['dailyTasks'] as List<dynamic>? ?? [])
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();

    // Full plan
    _fullPlan = (json['fullPlan'] as List<dynamic>? ?? [])
        .map((e) => PlanGroup.fromJson(e as Map<String, dynamic>))
        .toList();

    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggle(Task task) {
    setState(() {
      task.status = (task.status == 'done') ? 'pending' : 'done';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth * 0.7;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => {/* side menu */},
        ),
        title: SizedBox(
          width: tabWidth,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
      ),
      body: Column(
        children: [
          // 진행률 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.transparent,
                      minHeight: 20,
                    ),
                  ),
                ),
                Text(
                  '${(_progress * 100).round()}%',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 일일 목표
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dailyTasks.length,
                  itemBuilder: (_, i) {
                    final t = _dailyTasks[i];
                    final ignored = t.status == 'ignored';
                    return ListTile(
                      leading: Checkbox(
                        value: t.status == 'done',
                        onChanged: (_) => _toggle(t),
                        fillColor: ignored
                            ? MaterialStateProperty.all(Colors.red)
                            : null,
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(color: ignored ? Colors.red : null),
                      ),
                    );
                  },
                ),

                // 전체 목표 (캘린더 느낌)
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _fullPlan.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.date,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ...group.tasks.map((t) {
                          return ListTile(
                            leading: Checkbox(
                              value: t.status == 'done',
                              onChanged: (_) => _toggle(t),
                            ),
                            title: Text(t.title),
                            tileColor: t.status == 'ignored'
                                ? Colors.red.withOpacity(0.1)
                                : null,
                          );
                        }),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabInfo {
  final String id, label;
  TabInfo({required this.id, required this.label});
  factory TabInfo.fromJson(Map<String, dynamic> j) =>
      TabInfo(id: j['id'], label: j['label']);
}

class Task {
  final String id, title;
  String status; // "done" | "pending" | "ignored"
  Task({required this.id, required this.title, required this.status});
  factory Task.fromJson(Map<String, dynamic> j) => Task(
      id: j['id'], title: j['title'], status: j['status']);
}

class PlanGroup {
  final String date;
  final List<Task> tasks;
  PlanGroup({required this.date, required this.tasks});
  factory PlanGroup.fromJson(Map<String, dynamic> j) => PlanGroup(
    date: j['date'],
    tasks: (j['tasks'] as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
