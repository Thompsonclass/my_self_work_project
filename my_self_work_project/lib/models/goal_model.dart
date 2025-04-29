class GoalModel {
  String? category;
  String? type;
  String? duration;
  String? difficulty;

  GoalModel({
    this.category,
    this.type,
    this.duration,
    this.difficulty,
  });

  Map<String, dynamic> toJson(String userId) {
    return {
      'userId': userId,
      'category': category,
      'type': type,
      'duration': duration,
      'difficulty': difficulty,
    };
  }
}
