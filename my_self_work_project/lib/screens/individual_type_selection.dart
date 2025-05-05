// lib/pages/individual_type_selection.dart
import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'individual_duration_selection.dart';

class IndividualTypeSelectionScreen extends StatefulWidget {
  final GoalModel goalModel;
  const IndividualTypeSelectionScreen({required this.goalModel, Key? key})
      : super(key: key);

  @override
  _IndividualTypeSelectionScreenState createState() =>
      _IndividualTypeSelectionScreenState();
}

class _IndividualTypeSelectionScreenState
    extends State<IndividualTypeSelectionScreen> {
  // 카테고리별 추천 유형
  List<String> get _suggestions =>
      typesByCategory[widget.goalModel.category] ?? [];

  // 하나의 컨트롤러만 사용
  final TextEditingController _controller = TextEditingController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // 기존 모델 값이 있으면 초기화
    if (widget.goalModel.type != null) {
      _controller.text = widget.goalModel.type!;
      _selectedType = widget.goalModel.type;
    }
    // 컨트롤러 변경 감지는 여기서만
    _controller.addListener(() {
      setState(() {
        _selectedType = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => (_selectedType?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('세부 유형 입력 (2단계)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '카테고리 "${widget.goalModel.category}"의 구체적 유형을 입력하세요',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            Autocomplete<String>(
              // 제안 옵션 필터
              optionsBuilder: (TextEditingValue textValue) {
                final input = textValue.text;
                if (input.isEmpty) return const Iterable<String>.empty();
                return _suggestions.where((opt) =>
                    opt.toLowerCase().contains(input.toLowerCase()));
              },
              // 선택 시 controller만 업데이트
              onSelected: (selection) {
                _controller.text = selection;
                // _controller.addListener 에서 _selectedType 이 갱신됩니다.
              },
              // fieldViewBuilder 에서는 _controller만 지정
              fieldViewBuilder:
                  (context, fieldController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: _controller,  // 여기서만 사용
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: '세부 유형 입력',
                    hintText: '예: 아침 스트레칭, 저녁 독서 등',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => onFieldSubmitted(),
                );
              },
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _isValid
                  ? () {
                widget.goalModel.type = _selectedType!.trim();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        IndividualDurationSelectionScreen(goalModel: widget.goalModel),
                  ),
                );
              }
                  : null,
              child: const Text('다음: 기간 선택'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리별 추천 세부 유형 맵
const Map<String, List<String>> typesByCategory = {
  '건강': ['운동 루틴', '식단 관리', '수면 관리'],
  '생활': ['청소 루틴', '금연', '시간 관리'],
  '공부': ['자격증 공부', '영어 학습', '독서'],
};
