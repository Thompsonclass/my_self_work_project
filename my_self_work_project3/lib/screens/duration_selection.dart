import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'difficulty_selection.dart';

class DurationSelectionScreen extends StatefulWidget {
  final GoalModel goalModel;

  DurationSelectionScreen({required this.goalModel});

  // 🔵 3주일 추가!
  final List<String> durations = ['1주일', '2주일', '3주일', '한 달'];

  @override
  State<DurationSelectionScreen> createState() => _DurationSelectionScreenState();
}

class _DurationSelectionScreenState extends State<DurationSelectionScreen> {
  int? selectedIdx;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기간 선택'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      backgroundColor: const Color(0xfff6f9fe),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(widget.durations.length, (index) {
                final duration = widget.durations[index];
                final isSelected = selectedIdx == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => selectedIdx = index),
                    onTapUp: (_) {
                      widget.goalModel.period = duration;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DifficultySelectionScreen(goalModel: widget.goalModel),
                        ),
                      );
                    },
                    onTapCancel: () => setState(() => selectedIdx = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                          width: isSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.09),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            )
                          else
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          duration,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.blueAccent : Colors.black87,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
