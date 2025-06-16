import 'package:hive/hive.dart';
import '../models/goal_model.dart';

class GoalStorageService {
  static const String goalBoxName = 'goals';
  static const String sessionBoxName = 'goal_sessions';

  Future<void> saveGoal(GoalModel goal) async {
    final box = await Hive.openBox<GoalModel>(goalBoxName);
    await box.put('currentGoal', goal);
  }

  Future<GoalModel?> loadGoal() async {
    final box = await Hive.openBox<GoalModel>(goalBoxName);
    return box.get('currentGoal');
  }

  Future<void> clearGoal() async {
    final box = await Hive.openBox<GoalModel>(goalBoxName);
    await box.delete('currentGoal');
  }

  /// ✅ Task → GoalSession 저장/불러오기 메서드로 변경
  Future<void> saveSessions(List<GoalSession> sessions) async {
    final box = await Hive.openBox<GoalSession>(sessionBoxName);
    await box.clear(); // 기존 내용 비움
    for (var session in sessions) {
      if (session.id != null) {
        await box.put(session.id, session);
      }
    }
  }

  Future<List<GoalSession>> loadSessions() async {
    final box = await Hive.openBox<GoalSession>(sessionBoxName);
    return box.values.toList();
  }
}
