import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'summary_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final GoalModel goalModel;
  const DifficultySelectionScreen({required this.goalModel, Key? key})
      : super(key: key);

  @override
  _DifficultySelectionScreenState createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  final List<String> _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  List<bool> _selectedDays = List.generate(7, (_) => false);
  int _weeklyCount = 1;

  @override
  void initState() {
    super.initState();
    if (widget.goalModel.sessionsPerWeek != null) {
      _weeklyCount = widget.goalModel.sessionsPerWeek!;
    }

    if (widget.goalModel.selectedWeekdays != null) {
      for (var index in widget.goalModel.selectedWeekdays!) {
        if (index >= 0 && index < 7) {
          _selectedDays[index] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주간 스케줄 설정 (4단계)'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '1주일에 얼마나 할 건가요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: _weeklyCount.toDouble(),
                    min: 1.0,
                    max: 7.0,
                    divisions: 6,
                    label: '$_weeklyCount회',
                    onChanged: (val) {
                      setState(() {
                        _weeklyCount = val.round();
                      });
                    },
                  ),
                ),
                const Text('7'),
              ],
            ),
            Center(
              child: Text(
                '$_weeklyCount회 / 주',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              '어느 요일에 할 건가요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              itemCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, i) {
                final isSelected = _selectedDays[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDays[i] = !isSelected;
                      final selectedCount =
                          _selectedDays.where((e) => e).length;
                      if (selectedCount > _weeklyCount) {
                        _weeklyCount = selectedCount;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _weekdayLabels[i],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.goalModel.sessionsPerWeek = _weeklyCount;
                  widget.goalModel.selectedWeekdays = [
                    for (int i = 0; i < 7; i++)
                      if (_selectedDays[i]) i
                  ];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SummaryScreen(goalModel: widget.goalModel),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다음 (요약 화면으로)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
