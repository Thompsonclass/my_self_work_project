import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../models/goal_model.dart';
import '../pages/sign_in_page.dart';
import 'category_selection.dart';
import 'user_improvement_test.dart';

class LaunchRouter extends StatelessWidget {
  const LaunchRouter({super.key});

  Future<Widget> _decideNextScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ① 최초 사용자
      return const SignInPage();
    }

    // ②, ③, ④ → 기존 사용자
    final box = await Hive.openBox<GoalModel>('goals');
    final goal = box.get('currentGoal');

    if (goal != null) {
      // ④ 목표를 이미 생성한 사용자
      return UserImprovementScreen(goalModel: goal);
    } else {
      // ② 또는 ③ 로그인은 되어 있지만 목표가 없음
      return CategorySelectionScreen(goalModel: GoalModel());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideNextScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data!;
      },
    );
  }
}
