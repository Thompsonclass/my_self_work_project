import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart'; // AuthProvider import
import 'pages/sign_in_page.dart'; // 로그인 화면 import
import 'pages/sign_up_page.dart'; // 회원가입 화면 import
import 'pages/home_page.dart'; // 홈 화면 import


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
        title: 'DevSync',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/sign-up',
        routes: {
          '/sign-in': (context) => SignInPage(), // 로그인 화면 경로
          '/sign-up': (context) => SignUpPage(), // 회원가입 화면 경로
          '/home': (context) => HomeScreen(), // 홈 화면 경로
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
