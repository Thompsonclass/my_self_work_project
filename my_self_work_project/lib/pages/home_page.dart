import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // http 요청을 위한 패키지
import 'dart:convert'; // JSON 인코딩/디코딩

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeywordPage();
  }
}

class KeywordPage extends StatefulWidget {
  @override
  _KeywordPageState createState() => _KeywordPageState(); //상태 관리 클래스 생성
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
    var url = Uri.parse('http://...:8080/keywords');
    var body = jsonEncode({'keywords': selectedKeywords}); //선택된 키워드를 JSON으로 인코딩

    try {
      var response = await http.post( //HTTP POST 요청 전송
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("응답 상태코드: ${response.statusCode}");
      print("응답 바디: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("파싱된 데이터: $data");

        showDialog( //서버 응답을 다이얼로그로 표시
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("서버 응답"),
            content: Text(data['response']),
          ),
        );
      } else {
        print("요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("에러 발생: $e"); //예외 발생 시 콘솔에 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("키워드 선택기"),
        actions: [
          IconButton(  //로그아웃 버튼
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/sign-in'); //로그인 화면으로 이동
            },
          )
        ],
      ),
      body: Padding( //본문
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: Text('No user logged in'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Welcome, ${user.email}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You are now logged in!',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("키워드를 선택하세요:"),
            Wrap(
              spacing: 8,
              children: keywords.map((k) {
                final selected = selectedKeywords.contains(k); //선택 여부 확인
                return ChoiceChip(
                  label: Text(k),
                  selected: selected,
                  onSelected: (_) => toggleKeyword(k), //클릭시 반응
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: sendKeywords, //서버 전송 실행
                child: const Text("서버에 전송"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
