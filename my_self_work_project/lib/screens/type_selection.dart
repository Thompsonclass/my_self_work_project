import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'duration_selection.dart';

class TypeSelectionScreen extends StatelessWidget {
  final GoalModel goalModel;

  TypeSelectionScreen({required this.goalModel});

  final Map<String, List<String>> typesByCategory = { 
    '건강': ['다이어트 ', '근력운동'], // 수정
    '생활': ['금연', '독서'], //  수정 
    '공부': ['영단어 외우기', '자격증'], // 수정
  };

  @override
  Widget build(BuildContext context) {
    final types = typesByCategory[goalModel.category] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('유형 선택(2단계)')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: types.map((type) {
          return GestureDetector(
            onTap: () {
              goalModel.keyword = type; // ✅ 수정: type → keyword
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DurationSelectionScreen(goalModel: goalModel),
                ),
              );
            },
            child: Card(
              child: Center(
                child: Text(
                  type,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
