// 목표 설정에 사용되는 데이터 모델 클래스
class GoalModel {
  // 목표 카테고리 (예: 건강, 공부, 습관 등)
  String? category;

  // 목표 유형 (예: 독서, 운동, 코딩 등)
  String? type;

  // 기간 (예: 30일, 100일 등)
  String? duration;

  // 난이도 (예: 쉬움, 보통, 어려움 등)
  String? difficulty;

  // 주당 수행 횟수 (예: 주 3회 등)
  int? weeklyCount;

  // 선택된 요일 인덱스 리스트 (예: [1, 3, 5] → 화, 목, 토)
  List<int>? selectedWeekdays;

  // 하루 단위 세부 목표 설명 (예: 하루에 몇 분 할 건지 등)
  String? details;

  GoalModel({
    this.category,
    this.type,
    this.duration,
    this.difficulty,
    this.weeklyCount,
    this.selectedWeekdays,
    this.details,
  });
}