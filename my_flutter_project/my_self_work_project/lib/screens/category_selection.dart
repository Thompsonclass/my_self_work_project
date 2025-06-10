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
      appBar: AppBar(
        title: const Text('카테고리 선택 (1단계)'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                goalModel.category = category;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TypeSelectionScreen(goalModel: goalModel),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.blue.withOpacity(0.2),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.grey.withOpacity(0.4),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
