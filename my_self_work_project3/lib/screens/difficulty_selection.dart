import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'summary_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
  final GoalModel goalModel;
  const DifficultySelectionScreen({required this.goalModel, Key? key}) : super(key: key);

  @override
  _DifficultySelectionScreenState createState() => _DifficultySelectionScreenState();
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
        title: const Text('주간 스케줄 설정'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      backgroundColor: const Color(0xfff6f9fe),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
            Text(
              '1주일에 얼마나 실천할까요?',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 28),

            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 28, horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.17), width: 1.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.06),
                      blurRadius: 16,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27)),
                    SizedBox(
                      width: 270,
                      child: Slider(
                        value: _weeklyCount.toDouble(),
                        min: 1.0,
                        max: 7.0,
                        divisions: 6,
                        label: '$_weeklyCount회',
                        onChanged: (val) {
                          setState(() {
                            _weeklyCount = val.round();
                            // 선택된 요일 개수가 줄어들면 선택 해제
                            if (_selectedDays.where((e) => e).length > _weeklyCount) {
                              int count = 0;
                              for (int i = 0; i < 7; i++) {
                                if (_selectedDays[i]) {
                                  count++;
                                  if (count > _weeklyCount) _selectedDays[i] = false;
                                }
                              }
                            }
                          });
                        },
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.grey.shade300,
                        thumbColor: Colors.blueAccent,
                      ),
                    ),
                    const Text('7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 38),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  '$_weeklyCount회 / 주',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1),
                ),
              ),
            ),
            const SizedBox(height: 42),

            Text(
              '어느 요일에 할까요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 22),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => _buildDayButton(i, big: true)),
                ),
                const SizedBox(height: 23),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => _buildDayButton(i + 4, big: true)),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDays.where((e) => e).length == _weeklyCount
                    ? () {
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
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedDays.where((e) => e).length == _weeklyCount
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  '요약 확인 하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(int i, {bool big = false}) {
    final isSelected = _selectedDays[i];
    final double size = big ? 68 : 52;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            int selectedCount = _selectedDays.where((e) => e).length;
            if (!isSelected && selectedCount >= _weeklyCount) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("주당 횟수만큼만 선택할 수 있습니다!"),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.red.shade400,
                ),
              );
              return;
            }
            _selectedDays[i] = !isSelected;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.12),
                  blurRadius: 11,
                  offset: Offset(0, 4),
                )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _weekdayLabels[i],
            style: TextStyle(
              fontSize: big ? 23 : 19,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.blueAccent,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
