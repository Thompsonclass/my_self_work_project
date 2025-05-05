import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'individual_details_selection.dart';

// 난이도(주간 스케줄) 선택 화면
class IndividualDifficultySelectionScreen extends StatefulWidget {
  final GoalModel goalModel;
  const IndividualDifficultySelectionScreen({required this.goalModel, Key? key})
      : super(key: key);

  @override
  _DifficultySelectionScreenState createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState
    extends State<IndividualDifficultySelectionScreen> {
  // 요일 라벨 (월~일)
  final List<String> _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  // 선택된 요일 상태 저장 (7개: 월~일)
  List<bool> _selectedDays = List.generate(7, (_) => false);

  // 주당 수행 횟수 (기본값: 1)
  int _weeklyCount = 1;

  @override
  void initState() {
    super.initState();
    // 이전 화면에서 넘어온 goalModel 데이터 반영
    if (widget.goalModel.weeklyCount != null) {
      _weeklyCount = widget.goalModel.weeklyCount!;
    }
    if (widget.goalModel.selectedWeekdays != null) {
      for (var idx in widget.goalModel.selectedWeekdays!) {
        if (idx >= 0 && idx < 7) _selectedDays[idx] = true;
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
            // 주당 횟수
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
                    divisions: 6, // 1~7로 나눔
                    label: '$_weeklyCount회',
                    onChanged: (val) {
                      setState(() {
                        _weeklyCount = val.round(); // 실수를 정수로 반올림
                      });
                    },
                  ),
                ),
                const Text('7'),
              ],
            ),

            // 현재 선택된 주당 횟수 표시
            Center(
              child: Text(
                '$_weeklyCount회/주',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // 요일 선택 (ChoiceChip)
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

                      // 선택된 요일 수가 weeklyCount보다 많을 경우 count도 늘림
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

            // 다음 화면으로 이동 (요약 화면)
            ElevatedButton(
              onPressed: () {
                // 선택된 데이터 goalModel에 저장
                widget.goalModel.weeklyCount = _weeklyCount;
                widget.goalModel.selectedWeekdays = [
                  for (int i = 0; i < 7; i++) if (_selectedDays[i]) i
                ];

                // 요약 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        IndividualDetailsSelectionScreen(goalModel: widget.goalModel),
                  ),
                );
              },
              child: const Text('세부내용 설정'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
