import 'dart:convert';

class GoalStatisticsModel {
  final String category;
  final String keyword;
  final DateTime createdAt;
  final DateTime completedAt;
  final List<GoalSessionSummary> sessions;

  GoalStatisticsModel({
    required this.category,
    required this.keyword,
    required this.createdAt,
    required this.completedAt,
    required this.sessions,
  });

  factory GoalStatisticsModel.fromJson(Map<String, dynamic> json) {
    return GoalStatisticsModel(
      category: json['category'],
      keyword: json['keyword'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: DateTime.parse(json['completedAt']),
      sessions: (jsonDecode(json['sessionsJson']) as List)
          .map((e) => GoalSessionSummary.fromJson(e))
          .toList(),
    );
  }

  double get progress {
    if (sessions.isEmpty) return 0;
    final doneCount = sessions.where((s) => s.isCompleted).length;
    return doneCount / sessions.length;
  }
}

class GoalSessionSummary {
  final String dailyGoalDetail;
  final bool isCompleted;
  final DateTime sessionDate;

  GoalSessionSummary({
    required this.dailyGoalDetail,
    required this.isCompleted,
    required this.sessionDate
  });


  factory GoalSessionSummary.fromJson(Map<String, dynamic> json) {
    return GoalSessionSummary(
      dailyGoalDetail: json['dailyGoalDetail'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      sessionDate: DateTime.parse(json['sessionDate']),
    );
  }

}
