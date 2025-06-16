class ApiConstants {
  static const String baseUrl = 'http://192.168.0.5:8080/api';

  static const String fetchGoal = '$baseUrl/goals';
  static const String finalizeGoal = '$baseUrl/goals/finalize';
  static const String sessions = '$baseUrl/goals/sessions';
  static const String signUp = '$baseUrl/signup';

  static const String updateTask = '$baseUrl/tasks';
  static const String taskCreate = '$baseUrl/tasks/goal';

  static const String markSessionCompleted = '$baseUrl/goal-sessions';

  static const String todaySessions = '$baseUrl/goal-sessions/today';

}
