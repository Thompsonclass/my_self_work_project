import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants.dart';
import '../models/goal_model.dart';
import 'goal_storage_service.dart';

/// API 서버와의 통신을 담당하는 서비스 클래스
class ApiService {
  /// 1. GPT 서버로부터 목표 계획을 가져오는 함수
  static Future<List<dynamic>> fetchPlanFromGPT(String userEmail) async {
    final url = Uri.parse(ApiConstants.fetchGoal);

    try {
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
    } catch (e) {
      throw Exception('네트워크 오류 발생: $e');
    }
  }

  /// 2. 사용자 전체 세션(일별 목표) 목록을 가져오는 함수
  static Future<List<GoalSession>> fetchSessions(String email) async {
    final url = Uri.parse('${ApiConstants.sessions}?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      return List<GoalSession>.from(raw.map((item) => GoalSession.fromJson({
        'sessionDay': item['sessionDay'] ?? '',
        'dailyGoalDetail': item['dailyGoalDetail'] ?? '',
        'tip': item['tip'],
        'sessionDate': item['sessionDate'],
        'id': item['id'],
        'isComplete': item['isComplete'],
      })));
    } else {
      throw Exception('세션 불러오기 실패: ${response.statusCode}');
    }
  }

  /// 3. 사용자 회원가입 요청을 서버에 보내는 함수
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
        "nickname": nickname,
        "email": email,
        "uid": uid,
        "provider": provider,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('회원가입 실패: ${response.body}');
    }
  }

  /// 4. GoalSession 수정 요청 (PUT)
  static Future<void> updateSession(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/sessions/update');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("세션 업데이트 실패: ${response.body}");
    }
  }

  /// 5. 오늘 날짜 세션만 가져오기
  static Future<List<Map<String, dynamic>>> fetchTodaySessions(String email) async {
    final url = Uri.parse('${ApiConstants.todaySessions}?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
        raw.map((item) => {
          'id': item['id'],
          'date': item['sessionDate'],
          'title': item['dailyGoalDetail'],
          'tip': item['tip'],
          'isCompleted': item['isCompleted']
        }),
      );
    } else {
      throw Exception('오늘 세션 불러오기 실패: ${response.statusCode}');
    }
  }

  /// 6. 특정 세션을 완료로 표시
  static Future<void> markSessionAsCompleted(int sessionId) async {
    final url = Uri.parse('${ApiConstants.markSessionCompleted}/$sessionId/complete');

    final response = await http.put(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('세션 완료 처리 실패: ${response.body}');
    }
  }

  /// 7. 세션 리스트 서버와 Hive에 저장
  static Future<void> saveSessionsToServerAndHive(List<GoalSession> sessions, String goalId) async {
    List<GoalSession> savedSessions = [];

    for (var s in sessions) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConstants.taskCreate}/$goalId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "title": s.dailyGoalDetail,
            "tip": s.tip,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          savedSessions.add(
            GoalSession(
              sessionDay: data['sessionDay'] ?? '',
              dailyGoalDetail: data['title'] ?? '',
              tip: data['tip'],
              sessionDate: DateTime.parse(data['sessionDate']),
              id: data['id'],
              isComplete: false,
            ),
          );
        } else {
          print("서버 저장 실패: ${response.statusCode} / ${response.body}");
        }
      } catch (e) {
        print("세션 저장 중 예외 발생: $e");
      }
    }

    await GoalStorageService().saveSessions(savedSessions);
  }

  /// 8. 알림 시간 서버에 저장
  Future<void> sendAlarmTimeToServer(TimeOfDay time) async {
    await OneSignal.Notifications.requestPermission(true);
    final playerId = OneSignal.User.pushSubscription.id;

    if (playerId == null) {
      print("Player ID를 가져올 수 없습니다.");
      return;
    }

    final now = DateTime.now();
    final alarmDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formattedTime = alarmDateTime.toIso8601String();

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/notifications/set-time"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "playerId": playerId,
        "time": formattedTime,
      }),
    );

    if (response.statusCode == 200) {
      print("알림 시간이 서버에 저장되었습니다.");
    } else {
      print("서버 전송 실패: ${response.body}");
    }
  }

  /// 9. 통계 조회
  static Future<List<Map<String, dynamic>>> fetchStatistics(String email) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/statistics?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('통계 불러오기 실패');
    }
  }

  /// 10. 목표 존재 여부 확인
  static Future<bool> checkGoalExists(String email) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/goals/exists')
        .replace(queryParameters: {"email": email});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = response.body.trim();
      // Spring이 그냥 true/false 텍스트 리턴하는 경우 대응
      if (body == 'true') return true;
      if (body == 'false') return false;
      // 혹시 json boolean이면
      return jsonDecode(body) as bool;
    } else {
      throw Exception('목표 존재 여부 확인 실패');
    }
  }
}
