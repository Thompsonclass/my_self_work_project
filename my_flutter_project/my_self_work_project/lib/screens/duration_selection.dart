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
      appBar: AppBar(
        title: const Text('기간 선택 (3단계)'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: durations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final duration = durations[index];
            return InkWell(
              onTap: () {
                goalModel.period = duration;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DifficultySelectionScreen(goalModel: goalModel),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.blue.withOpacity(0.1),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: Colors.grey.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Center(
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
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
