import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/goal_model.dart';
import 'providers/auth_provider.dart'; // AuthProvider import
import 'pages/sign_in_page.dart'; // 로그인 화면 import
import 'pages/sign_up_page.dart'; // 회원가입 화면 import
import 'pages/home_page.dart'; // 홈 화면 import

import 'screens/category_selection.dart';
import 'screens/type_selection.dart';
import 'screens/duration_selection.dart';
import 'screens/difficulty_selection.dart';
import 'screens/summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart에서 자동 생성된 코드 사용
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // AuthProvider 등록
      ],
      child: MaterialApp(
        title: 'OnePointUp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/sign-up', // 기본 화면은 회원가입 화면으로 시작
        routes: {
          '/sign-in': (context) => SignInPage(), // 로그인 화면 경로
          '/sign-up': (context) => SignUpPage(), // 회원가입 화면 경로
          '/home': (context) => HomeScreen(), // 홈 화면 경로

          // 목표 설정 플로우 라우트
          '/select-category': (context) => CategorySelectionScreen(goalModel: GoalModel(),),
          '/select-type': (context) => TypeSelectionScreen(goalModel: GoalModel(),),
          '/select-duration': (context) => DurationSelectionScreen(goalModel: GoalModel(),),
          '/select-difficulty': (context) => DifficultySelectionScreen(goalModel: GoalModel(),),
          '/summary': (context) => SummaryScreen(goalModel: GoalModel(),),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
