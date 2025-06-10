import 'package:hive/hive.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart' as model;
import '../screens/user_improvement.dart' as screen;

class GoalStorageService {
  static const String boxName = 'goals';
  static const String taskBoxName = 'tasks';

  Future<void> saveGoal(GoalModel goal) async {
    final box = await Hive.openBox<GoalModel>(boxName);
    await box.put('currentGoal', goal);
  }

  Future<GoalModel?> loadGoal() async {
    final box = await Hive.openBox<GoalModel>(boxName);
    return box.get('currentGoal');
  }

  Future<void> clearGoal() async {
    final box = await Hive.openBox<GoalModel>(boxName);
    await box.delete('currentGoal');
  }
  Future<void> saveTasks(List<model.Task> tasks) async {
    final box = await Hive.openBox<model.Task>(taskBoxName);
    await box.clear();
    for (int i = 0; i < tasks.length; i++) {
      await box.put(i, tasks[i]);
    }
  }

  Future<List<model.Task>> loadTasks() async {
    final box = await Hive.openBox<model.Task>(taskBoxName);
    return box.values.toList();
  }
}
