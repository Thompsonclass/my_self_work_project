// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalSessionAdapter extends TypeAdapter<GoalSession> {
  @override
  final int typeId = 1;

  @override
  GoalSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalSession(
      id: fields[4] as int?,
      sessionDay: fields[0] as String,
      dailyGoalDetail: fields[1] as String,
      sessionDate: fields[3] as DateTime,
      isComplete: fields[5] as bool,
      tip: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GoalSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sessionDay)
      ..writeByte(1)
      ..write(obj.dailyGoalDetail)
      ..writeByte(2)
      ..write(obj.tip)
      ..writeByte(3)
      ..write(obj.sessionDate)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.isComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 0;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel(
      id: fields[0] as int?,
      email: fields[1] as String?,
      category: fields[2] as String?,
      keyword: fields[3] as String?,
      period: fields[4] as String?,
      difficulty: fields[5] as String?,
      sessionsPerWeek: fields[6] as int?,
      selectedWeekdays: (fields[7] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.keyword)
      ..writeByte(4)
      ..write(obj.period)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.sessionsPerWeek)
      ..writeByte(7)
      ..write(obj.selectedWeekdays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 2;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.pending;
      case 1:
        return TaskStatus.done;
      case 2:
        return TaskStatus.ignored;
      default:
        return TaskStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.pending:
        writer.writeByte(0);
        break;
      case TaskStatus.done:
        writer.writeByte(1);
        break;
      case TaskStatus.ignored:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
