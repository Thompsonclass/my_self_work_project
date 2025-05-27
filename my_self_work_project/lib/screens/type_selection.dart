import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'duration_selection.dart';

class TypeSelectionScreen extends StatelessWidget {
  final GoalModel goalModel;

  TypeSelectionScreen({required this.goalModel});

  final Map<String, List<String>> typesByCategory = {
    '건강': ['다이어트', '근력운동'],
    '생활': ['금연', '독서'],
    '공부': ['영단어 외우기', '자격증'],
  };

  @override
  Widget build(BuildContext context) {
    final types = typesByCategory[goalModel.category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('유형 선택 (2단계)'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: types.isEmpty
            ? const Center(child: Text("선택 가능한 유형이 없습니다."))
            : GridView.builder(
          itemCount: types.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final type = types[index];
            return InkWell(
              onTap: () {
                goalModel.keyword = type;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DurationSelectionScreen(goalModel: goalModel),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.blue.withOpacity(0.2),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Colors.grey.withOpacity(0.4),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
