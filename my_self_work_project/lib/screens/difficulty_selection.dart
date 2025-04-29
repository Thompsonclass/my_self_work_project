import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'summary_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final GoalModel goalModel;

  DifficultySelectionScreen({required this.goalModel});

  final List<String> difficulties = ['하(일주일에 1~2번)', '중(일주일에3~4번)', '상(일주일에5일이상)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('난이도 선택')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: difficulties.map((difficulty) {
          return ListTile(
            title: Text(difficulty),
            onTap: () {
              goalModel.difficulty = difficulty;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SummaryScreen(goalModel: goalModel),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
