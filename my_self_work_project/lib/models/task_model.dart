import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2)
enum TaskStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  done,

  @HiveField(2)
  ignored,
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String tip;

  @HiveField(2)
  TaskStatus status;

  Task({
    required this.title,
    required this.tip,
    this.status = TaskStatus.pending,
  });
}
