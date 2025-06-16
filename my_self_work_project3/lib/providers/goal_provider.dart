import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../models/goal_statistics_model.dart';
import '../services/api_service.dart';

class GoalProvider with ChangeNotifier {
  GoalModel? _goal;
  String? _email;

  List<GoalSession> _sessions = [];

  List<GoalStatisticsModel> statistics = [];

  GoalModel? get goal => _goal;
  String? get email => _email;

  List<GoalSession> get sessions => _sessions;

  List<GoalSession> _statisticsSessions = [];
  List<GoalSession> get statisticsSessions => _statisticsSessions;

  Future<void> loadStatistics(String email) async {
    try {
      final rawList = await ApiService.fetchStatistics(email);
      statistics = rawList.map((e) => GoalStatisticsModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      print("[GoalProvider] 통계 로드 실패: $e");
    }
  }

  // 필요 시 초기화 메서드도 추가 가능
  void clearStatistics() {
    statistics.clear();
    notifyListeners();
  }

  // Future<void> loadStatistics(String email) async {
  //   final rawData = await ApiService.fetchStatistics(email);
  //   _statisticsSessions = rawData.map((e) => GoalSession.fromJson(e)).toList();
  //   notifyListeners();
  // }

  void setGoal(GoalModel goal, {String? email}) {
    _goal = goal;
    if (email != null) _email = email;
    notifyListeners();
  }

  set sessions(List<GoalSession> newSessions) {
    _sessions = newSessions;
    notifyListeners();
  }

  void clearGoal() {
    _goal = null;
    _email = null;
    _sessions = [];
    notifyListeners();
  }

}
