import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://###.##.#.#:8080'; // ← IP는 여기에만

  /// [goalJsonString]은 GoalModel의 toJsonString()으로부터 전달되는 JSON 문자열
  /// 예시:
  /// {
  ///   "email": "user@example.com",
  ///   "category": "운동",
  ///   "keyword": "헬스",
  ///   "period": "4주",
  ///   "includeWeekend": true,
  ///   "selectedWeekdays": ["월", "수", "금"],
  ///   "sessionsPerWeek": 3
  /// }
  static Future<void> postGoal(String goalJsonString) async {
    final url = Uri.parse('$baseUrl/api/goals');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: goalJsonString,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('목표 전송 실패: ${response.body}');
    }
  }

  /// 사용자 닉네임, 이메일, 비밀번호를 JSON으로 전송
  /// 요청 JSON:
  /// {
  ///   "username": "홍길동",
  ///   "email": "hong@example.com",
  ///   "password": "1234abcd"
  /// }
  static Future<void> signUpUser({
    required String nickname,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/userId');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": nickname,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('회원가입 실패: ${response.body}');
    }
  }
}
