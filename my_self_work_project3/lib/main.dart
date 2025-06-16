import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:my_self_work_project/providers/goal_provider.dart';
import 'package:my_self_work_project/screens/CategoryKeywordSelectionScreen.dart';
import 'package:my_self_work_project/screens/improvement_shell.dart';
import 'package:my_self_work_project/screens/launch_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'models/goal_model.dart';
import 'providers/auth_provider.dart';

import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/home_page.dart';

import 'screens/duration_selection.dart';
import 'screens/difficulty_selection.dart';
import 'screens/summary_screen.dart';

import 'screens/user_setting_screen.dart';
import 'screens/user_stat_screen.dart';

import 'package:http/http.dart' as http;

/// 🔁 서버에 마감된 목표를 통계 테이블로 이동 요청
Future<void> migrateExpiredGoals() async {
  final url = Uri.parse('${ApiConstants.baseUrl}/goals/migrate');

  try {
    final response = await http.post(url);
    if (response.statusCode == 200) {
      print('목표 마이그레이션 성공: ${response.body}');
    } else {
      print('마이그레이션 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('네트워크 오류: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔁 앱 시작 시 자동으로 마감된 목표를 서버로 이동
  await migrateExpiredGoals();

  OneSignal.initialize("ce2fcdc2-c8a0-4532-926d-9be5f9a33fa8");
  await OneSignal.Notifications.requestPermission(true);

  await Hive.initFlutter();
  Hive.registerAdapter(GoalModelAdapter());
  Hive.registerAdapter(GoalSessionAdapter());
  Hive.registerAdapter(TaskStatusAdapter());

  await Hive.openBox<GoalModel>('goals');
  await Hive.openBox<GoalSession>('goal_sessions');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: MaterialApp(
        title: 'OnePointUp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LaunchRouter(),
        routes: {
          '/sign-in': (context) => SignInPage(),
          '/sign-up': (context) => SignUpPage(),
          '/home': (context) => HomeScreen(),

          // 📦 GPT 목표 설정: 카테고리+키워드 통합!
          '/select-category': (context) => CategoryKeywordSelectionScreen(goalModel: GoalModel()),
          '/select-duration': (context) => DurationSelectionScreen(goalModel: GoalModel()),
          '/select-difficulty': (context) => DifficultySelectionScreen(goalModel: GoalModel()),
          '/summary': (context) => SummaryScreen(goalModel: GoalModel()),

          // 메인 기능
          '/improvement': (context) => const ImprovementShell(),
          '/setting': (context) => const UserSettingsScreen(),
          '/stat': (context) => const UserStatsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
