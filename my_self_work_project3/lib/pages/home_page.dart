import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:hive/hive.dart';
import 'package:my_self_work_project/pages/sign_in_page.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as authPovider;
import '../models/goal_model.dart';
import '../screens/CategoryKeywordSelectionScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f9fe),
      appBar: AppBar(
        title: const Text('목표 설정 홈'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              final box = await Hive.openBox<GoalModel>('goals');
              await box.delete('currentGoal'); // 캐시 삭제
              await Provider.of<authPovider.AuthProvider>(context, listen: false).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('로그인 상태가 아닙니다.'));
          }

          final displayName = user.displayName ?? user.email;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 둥근 그림자 카드로 감싼 인사
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  margin: const EdgeInsets.only(bottom: 36),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(20),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 56,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '환영합니다.\n$displayName',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.38,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'One-Point-Up과 함께\n작은 실천을 시작해보세요!',
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // 박스 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryKeywordSelectionScreen(goalModel: GoalModel()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.flag, size: 28),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.5),
                      child: Text(
                        '인공지능 목표 설정 시작',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
