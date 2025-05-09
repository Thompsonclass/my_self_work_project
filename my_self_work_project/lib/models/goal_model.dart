import 'dart:convert';

/// 개별 목표 세션을 나타내는 클래스
class GoalSession {
  final String sessionDay;
  final String dailyGoalDetail;

  GoalSession({required this.sessionDay, required this.dailyGoalDetail});

  Map<String, dynamic> toJson() => {
    "sessionDay": sessionDay,
    "dailyGoalDetail": dailyGoalDetail,
  };
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

  List<String>? get selectedWeekdayLabels {
    if (selectedWeekdays == null) return null;
    const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    return selectedWeekdays!.map((i) => weekdayLabels[i]).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "category": category,
      "keyword": keyword,
      "period": period,
      "includeWeekend": true,
      "selectedWeekdays": selectedWeekdayLabels,
      "sessionsPerWeek": sessionsPerWeek,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
