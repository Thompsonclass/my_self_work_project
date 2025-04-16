import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: KeywordPage());
  }
}

class KeywordPage extends StatefulWidget {
  @override
  _KeywordPageState createState() => _KeywordPageState();
}

class _KeywordPageState extends State<KeywordPage> {
  final List<String> keywords = ['AI', 'Flutter', 'Spring', 'Dart', 'Python'];
  final List<String> selectedKeywords = [];

  void toggleKeyword(String keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword)) {
        selectedKeywords.remove(keyword);
      } else {
        selectedKeywords.add(keyword);
      }
    });
  }

  void sendKeywords() async {
    var url = Uri.parse('http://192.168.50.229:8080/keywords');
    var body = jsonEncode({'keywords': selectedKeywords});

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("응답 상태코드: ${response.statusCode}");
      print("응답 바디: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("파싱된 데이터: $data");

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("서버 응답"),
            content: Text(data['response']),
          ),
        );
      } else {
        print("요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("키워드 선택기")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: keywords.map((k) {
                final selected = selectedKeywords.contains(k);
                return ChoiceChip(
                  label: Text(k),
                  selected: selected,
                  onSelected: (_) => toggleKeyword(k),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendKeywords,
              child: Text("서버에 전송"),
            ),
          ],
        ),
      ),
    );
  }
}
