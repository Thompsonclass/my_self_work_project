import 'dart:convert';
import 'package:hive/hive.dart';

part 'goal_model.g.dart'; // 이 줄 반드시 필요!

/// 개별 목표 세션을 나타내는 클래스
@HiveType(typeId: 1)
class GoalSession extends HiveObject {
  @HiveField(0)
  final String sessionDay;

  @HiveField(1)
  final String dailyGoalDetail;

  @HiveField(2)
  final String? tip;

  @HiveField(3)
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

@HiveType(typeId: 0)
class GoalModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? category;

  @HiveField(3)
  String? keyword;

  @HiveField(4)
  String? period;

  @HiveField(5)
  String? difficulty;

  @HiveField(6)
  int? sessionsPerWeek;

  @HiveField(7)
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
