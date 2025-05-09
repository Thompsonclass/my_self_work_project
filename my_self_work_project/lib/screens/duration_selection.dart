import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'difficulty_selection.dart';

class DurationSelectionScreen extends StatelessWidget {
  final GoalModel goalModel;

  DurationSelectionScreen({required this.goalModel});

  final List<String> durations = ['1주일', '2주일', '한 달'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기간 선택(3단계)')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: durations.map((duration) {
          return ListTile(
            title: Text(duration),
            onTap: () {
              goalModel.period = duration;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DifficultySelectionScreen(goalModel: goalModel),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
