import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator 사용
import 'package:my_self_work_project/models/goal_model.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import 'user_improvement_test.dart';
import 'user_setting_screen.dart';
import 'user_stat_screen.dart';

class ImprovementShell extends StatefulWidget {
  const ImprovementShell({Key? key}) : super(key: key);

  @override
  State<ImprovementShell> createState() => _ImprovementShellState();
}

class _ImprovementShellState extends State<ImprovementShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<GoalProvider>().goal;

    if (goal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const SizedBox();
    }

    final screens = [
      const UserImprovementScreen(),
      const UserSettingsScreen(),
      const UserStatsScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 앱 종료
        await Future.delayed(const Duration(milliseconds: 80)); // 애니메이션 자연스럽게
        SystemNavigator.pop();
        return false; // 뒤로가기 막음
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
          ],
        ),
      ),
    );
  }
}
