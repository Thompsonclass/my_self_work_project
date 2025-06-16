import 'dart:convert';
import 'package:hive/hive.dart';

part 'goal_model.g.dart';

/// TaskStatus enum은 별도로 정의하며 typeId는 고유해야 함
@HiveType(typeId: 2)
enum TaskStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  done,

  @HiveField(2)
  ignored,
}

/// GoalSession은 기존 Task 역할을 통합해서 확장
@HiveType(typeId: 1)
class GoalSession extends HiveObject {
  @HiveField(0)
  String sessionDay;

  @HiveField(1)
  String dailyGoalDetail;

  @HiveField(2)
  String? tip;

  @HiveField(3)
  DateTime sessionDate;

  @HiveField(4)
  int? id;

  @HiveField(5) // ✅ 새 필드에 고유 인덱스 부여
  bool isComplete;

  GoalSession({
    required this.id,
    required this.sessionDay,
    required this.dailyGoalDetail,
    required this.sessionDate,
    required this.isComplete,
    this.tip, // ✅ 기본값 false
  });

  factory GoalSession.fromJson(Map<String, dynamic> json) {
    return GoalSession(
      id: json['id'],
      sessionDay: json['sessionDay'] ?? '',
      dailyGoalDetail: json['dailyGoalDetail'] ?? '',
      tip: json['tip'],
      sessionDate: DateTime.parse(json['sessionDate']),
      isComplete: json['isComplete'] == true,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'sessionDay': sessionDay,
      'dailyGoalDetail': dailyGoalDetail,
      'tip': tip,
      'sessionDate': sessionDate.toIso8601String(),
      'id': id,
      'isComplete': isComplete,
    };
  }
}

/// 기존의 전체 목표 설정 데이터 (변경 없음)
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
      "selectedDays":
      selectedWeekdays?.map((i) => weekdayLabel[i]).toList() ?? [],
    };
  }

  static const List<String> weekdayLabel = ['월', '화', '수', '목', '금', '토', '일'];

  String toJsonString() => jsonEncode(toJson());

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    // selectedWeekdays는 요일 문자열(월~일) 리스트나 인덱스 리스트 등 다양한 형태가 들어올 수 있으니 보정
    List<int>? parseWeekdays(dynamic data) {
      if (data == null) return null;
      // 1. 숫자 리스트면 그대로 반환
      if (data is List && data.isNotEmpty && data.first is int) {
        return List<int>.from(data);
      }
      // 2. 문자열(월~일) 리스트면 인덱스 매핑
      if (data is List && data.isNotEmpty && data.first is String) {
        return data
            .map((e) => weekdayLabel.indexOf(e))
            .where((i) => i >= 0)
            .toList();
      }
      return null;
    }

    return GoalModel(
      id: json['id'],
      email: json['email'],
      category: json['category'],
      keyword: json['keyword'],
      period: json['period'],
      difficulty: json['difficulty'],
      sessionsPerWeek: json['sessionsPerWeek'],
      selectedWeekdays: parseWeekdays(json['selectedWeekdays'] ?? json['selectedDays']),
    );
  }

}
