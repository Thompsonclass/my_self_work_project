import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../pages/sign_in_page.dart';
import '../providers/goal_provider.dart';
import '../services/api_service.dart';
import 'ErrorScreen.dart';
import '../pages/home_page.dart';
import 'improvement_shell.dart';

class LaunchRouter extends StatelessWidget {
  const LaunchRouter({super.key});

  Future<Widget> _decideNextScreen(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const SignInPage();

    final email = user.email!;
    try {
      final goalExists = await ApiService.checkGoalExists(email);

      if (goalExists) {
        final box = await Hive.openBox<GoalModel>('goals');
        final storedGoal = box.get('currentGoal');
        if (storedGoal != null) {
          Provider.of<GoalProvider>(context, listen: false).setGoal(storedGoal);
        }
        return const ImprovementShell();
      } else {
        return const HomeScreen(); // 목표 없을 경우
      }
    } catch (e) {
      return ErrorScreen(message: "초기화 중 오류 발생: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideNextScreen(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) return snapshot.data!;
          if (snapshot.hasError) {
            return ErrorScreen(message: "초기화 오류: ${snapshot.error}");
          }
          return const ErrorScreen(message: "데이터 없음");
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
