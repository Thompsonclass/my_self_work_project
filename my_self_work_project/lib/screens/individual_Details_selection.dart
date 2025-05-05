import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'individual_summary_screen.dart';

class IndividualDetailsSelectionScreen extends StatefulWidget {
  final GoalModel goalModel;
  const IndividualDetailsSelectionScreen({required this.goalModel, Key? key})
      : super(key: key);

  @override
  _IndividualDetailsSelectionScreenState createState() =>
      _IndividualDetailsSelectionScreenState();
}

class _IndividualDetailsSelectionScreenState
    extends State<IndividualDetailsSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 텍스트가 바뀔 때마다 rebuild
    _detailsController.addListener(() => setState(() {}));

    if (widget.goalModel.details != null) {
      _detailsController.text = widget.goalModel.details!;
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  bool get _isValid => _formKey.currentState?.validate() ?? false;

  void _onNext() {
    if (!_isValid) return;
    widget.goalModel.details = _detailsController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IndividualSummaryScreen(goalModel: widget.goalModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // 현재 선택된 type 에 따른 힌트
    final hint = detailsHintByType[widget.goalModel.type]
        ?? '세부 내용을 입력하세요';

    return Scaffold(
      appBar: AppBar(
        title: const Text('세부 목표 입력 (6단계)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '하루에 달성해야 하는 세부 내용을 입력하세요',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: '세부 내용',
                  hintText: hint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: null,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '세부 내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isValid ? _onNext : null,
                child: const Text('다음: 최종 확인'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// type 별 세부 입력 힌트 맵
const Map<String, String> detailsHintByType = {
  // 건강 카테고리
  '운동 루틴': '예: 아침 스트레칭 10분, 저녁 러닝 30분',
  '식단 관리': '예: 아침 샐러드, 점심 닭가슴살, 저녁 샐러드',
  '수면 관리': '예: 22시 취침, 7시 기상',

  // 생활 카테고리
  '청소 루틴': '예: 방 청소 10분, 거실 정리 15분',
  '금연': '예: 니코틴 패치 사용 3시간',
  '시간 관리': '예: 일정표에 30분 단위로 업무 블록 설정',

  // 공부 카테고리
  '자격증 공부': '예: 하루 단원별 문제 20개 풀기',
  '영어 학습': '예: 영어 단어 20개 암기',
  '독서': '예: 하루 30페이지 읽기',
};
