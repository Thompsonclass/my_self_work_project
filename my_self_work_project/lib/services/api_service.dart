import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://###.##.#.#:8080'; // ← IP는 여기에만

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

  static Future<List<dynamic>> fetchPlanFromGPT(String userEmail) async {
    final url = Uri.parse('$baseUrl/api/goals');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": userEmail}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('계획 불러오기 실패: ${response.statusCode}');
    }
  }

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
