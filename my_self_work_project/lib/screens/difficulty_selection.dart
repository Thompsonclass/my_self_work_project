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

class _DifficultySelectionScreenState
    extends State<DifficultySelectionScreen> {
  final List<String> _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  List<bool> _selectedDays = List.generate(7, (_) => false);
  int _weeklyCount = 1;

  @override
  void initState() {
    super.initState();
    if (widget.goalModel.sessionsPerWeek != null) {
      _weeklyCount = widget.goalModel.sessionsPerWeek!;
    }

    // 선택된 요일 복원 (goalSessions 제거됨 → selectedWeekdays 기준으로)
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('주간 스케줄 설정 (4단계)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('1주일에 얼마나 할 건가요?', style: textTheme.titleMedium),
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
                '$_weeklyCount회/주',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            Text('어느 요일에 할 건가요?', style: textTheme.titleMedium),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                return ChoiceChip(
                  avatar: CircleAvatar(child: Text(_weekdayLabels[i])),
                  label: Text(_weekdayLabels[i]),
                  selected: _selectedDays[i],
                  onSelected: (sel) {
                    setState(() {
                      _selectedDays[i] = sel;
                      final selectedCount = _selectedDays.where((e) => e).length;
                      if (selectedCount > _weeklyCount) {
                        _weeklyCount = selectedCount;
                      }
                    });
                  },
                );
              }),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                // 저장
                widget.goalModel.sessionsPerWeek = _weeklyCount;
                widget.goalModel.selectedWeekdays = [
                  for (int i = 0; i < 7; i++)
                    if (_selectedDays[i]) i
                ];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SummaryScreen(goalModel: widget.goalModel),
                  ),
                );
              },
              child: const Text('다음 (요약 화면으로)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
