import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'type_selection.dart';

class CategorySelectionScreen extends StatelessWidget {
  final GoalModel goalModel;

  CategorySelectionScreen({required this.goalModel});

  final List<String> categories = ['건강', '생활', '공부'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리 선택')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () {
              goalModel.category = category;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TypeSelectionScreen(goalModel: goalModel),
                ),
              );
            },
            child: Card(
              child: Center(child: Text(category, style: const TextStyle(fontSize: 18))),
            ),
          );
        }).toList(),
      ),
    );
  }
}
