import 'dart:convert';

/// 개별 목표 세션을 나타내는 클래스
class GoalSession {
  final String sessionDay;
  final String dailyGoalDetail;
  final String? tip;
  final DateTime sessionDate;

  GoalSession({
    required this.sessionDay,
    required this.dailyGoalDetail,
    required this.sessionDate,
    this.tip,
  });

  factory GoalSession.fromJson(Map<String, dynamic> json) {
    return GoalSession(
      sessionDay: json['sessionDay'],
      dailyGoalDetail: json['dailyGoalDetail'],
      tip: json['tip'],
      sessionDate: DateTime.parse(json['sessionDate']),
    );
  }
}

class GoalModel {
  int? id;
  String? email;
  String? category;
  String? keyword;
  String? period;
  String? difficulty;
  int? sessionsPerWeek;
  List<int>? selectedWeekdays;

  GoalModel({
    this.id,
    this.email,
    this.category,
    this.keyword,
    this.period,
    this.difficulty,
    this.sessionsPerWeek,
    this.selectedWeekdays,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "category": category,
      "keyword": keyword,
      "period": period,
      "sessionsPerWeek": sessionsPerWeek,
      "selectedDays": selectedWeekdays?.map((i) => weekdayLabel[i]).toList() ?? [],
    };
  }

  static const List<String> weekdayLabel = ['월', '화', '수', '목', '금', '토', '일'];


  String toJsonString() => jsonEncode(toJson());
}
