import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  static Future<List<dynamic>> fetchPlanFromGPT(String userEmail) async {
    final url = Uri.parse(ApiConstants.fetchGoal);

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

  static Future<List<Map<String, dynamic>>> fetchSessions(String email) async {
    final url = Uri.parse('${ApiConstants.sessions}?email=$email');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(
        raw.where((item) =>
        item['sessionDate'] != null && item['dailyGoalDetail'] != null).map(
              (item) => {
            'date': item['sessionDate'] ?? '',
            'title': item['dailyGoalDetail'] ?? '',
            'tip': item['tip'] ?? ''
          },
        ),
      );
    } else {
      throw Exception('세션 불러오기 실패: ${response.statusCode}');
    }
  }


  static Future<void> signUpUser({
    required String nickname,
    required String email,
    required String uid,
    required String provider,
  }) async {
    final url = Uri.parse(ApiConstants.signUp);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "uid": uid,
        "nickname": nickname,
        "provider": provider,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('회원가입 실패: ${response.body}');
    }
  }

}
