import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'duration_selection.dart';

class CategoryKeywordSelectionScreen extends StatefulWidget {
  final GoalModel goalModel;
  const CategoryKeywordSelectionScreen({Key? key, required this.goalModel}) : super(key: key);

  @override
  State<CategoryKeywordSelectionScreen> createState() => _CategoryKeywordSelectionScreenState();
}

class _CategoryKeywordSelectionScreenState extends State<CategoryKeywordSelectionScreen> {
  final List<Map<String, dynamic>> categoryList = [
    {'label': '건강', 'icon': Icons.favorite},
    {'label': '생활', 'icon': Icons.home},
    {'label': '공부', 'icon': Icons.school},
  ];

  final Map<String, List<String>> keywordMap = {
    '건강': [
      '식단 관리',
      '홈트레이닝',
      '체중 감량',
      '유산소 운동',
      '아침 운동',
      '근육 만들기',
      '수면 습관',
      '물 많이 마시기',
      '명상',
    ],
    '생활': [
      '독서 습관',
      '아침 루틴 만들기',
      '집 청소',
      '돈 관리',
      '미니멀리즘',
      '디지털 디톡스',
      '감사 일기 쓰기',
      '하루 1정리',
      '정리정돈',
    ],
    '공부': [
      '영어 단어 암기',
      '토익 공부',
      '자격증 준비',
      '코딩 공부',
      '독서 정리',
      '인강 듣기',
      '회화 연습',
      '수학 복습',
      '하루 1문제',
    ],
  };


  String? selectedCategory;
  String? selectedKeyword;

  @override
  void initState() {
    super.initState();
    selectedCategory = categoryList.first['label'];
  }

  // ... (생략) 기존 State 클래스 내에서

  @override
  Widget build(BuildContext context) {
    final keywords = keywordMap[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 유형 선택'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xfff6f9fe),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리: Row로 3개 한 줄에!
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: categoryList.map((cat) {
                  final bool isSelected = cat['label'] == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat['label'];
                          selectedKeyword = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 170),
                        width: 100,
                        // 👈 여기 크기 조절 (예전엔 112)
                        height: 100,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? Colors.blueAccent : Colors.grey
                                .shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.09),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.06),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat['icon'], size: 28,
                                color: isSelected ? Colors.blueAccent : Colors
                                    .grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected ? Colors.blueAccent : Colors
                                    .black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // 이하 동일 (유형 선택 등)
            const SizedBox(height: 32),
            Text(
              "키워드 선택",
              style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: keywords.map((kw) {
                final bool isSelected = kw == selectedKeyword;
                return ChoiceChip(
                  label: Text(
                    kw,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blueAccent : Colors.grey[700],
                      fontSize: 15,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected ? Colors.blueAccent : Colors.grey
                          .shade300,
                      width: 1.7,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedKeyword = kw;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedKeyword != null
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
                  minimumSize: const Size(140, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
                onPressed: selectedKeyword != null
                    ? () {
                  widget.goalModel.category = selectedCategory!;
                  widget.goalModel.keyword = selectedKeyword!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DurationSelectionScreen(goalModel: widget.goalModel),
                    ),
                  );
                }
                    : null,
                child: const Text(
                  '선택 완료',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}