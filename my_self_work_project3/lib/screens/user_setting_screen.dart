import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/goal_model.dart';
import '../pages/sign_in_page.dart';
import '../providers/auth_provider.dart' as authPovider;
import '../providers/goal_provider.dart';
import 'ErrorScreen.dart'; // 홈

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTimeAndSendToServer() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(primary: Colors.blueAccent),
        ),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);

      //  알림 권한 요청
      await OneSignal.Notifications.requestPermission(true);
      final playerId = OneSignal.User.pushSubscription.id;

      if (playerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("알림 토큰을 가져올 수 없습니다.")),
        );
        return;
      }

      final now = DateTime.now();
      final targetTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      try {
        final response = await http.post(
          Uri.parse("http://192.168.45.179/api/notifications/set-time"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "playerId": playerId,
            "time": targetTime.toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("알림 시간이 저장되었습니다.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("서버 오류: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("네트워크 오류: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '로그인 정보 없음';

    final goal = context.watch<GoalProvider>().goal;
    if (goal == null) return const ErrorScreen(message: "목표 정보 없음");

    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: const Color(0xfff6f9fe),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 6),
          _sectionTitle("계정 정보"),
          _settingCard(
            icon: Icons.email,
            iconColor: Colors.blueAccent,
            title: "이메일",
            subtitle: email,
          ),
          const SizedBox(height: 30),

          _sectionTitle("환경 설정"),
          _settingCard(
            icon: Icons.notifications_active,
            iconColor: Colors.orange.shade400,
            title: "알림 시간",
            subtitle: _selectedTime == null
                ? "설정하지 않음"
                : "오늘 ${_selectedTime!.format(context)}에 알림",
            trailing: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: _pickTimeAndSendToServer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit, size: 19, color: Colors.blueAccent),
                    SizedBox(width: 3),
                    Text('변경', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            onTap: _pickTimeAndSendToServer,
          ),
          const SizedBox(height: 30),

          _sectionTitle("기타"),
          Card(
            elevation: 3,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: 43,
                    height: 43,
                    child: const Icon(Icons.info_outline, color: Colors.blueAccent),
                  ),
                  title: const Text("앱 정보", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("버전 1.0.0"),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: 43,
                    height: 43,
                    child: const Icon(Icons.logout, color: Colors.redAccent),
                  ),
                  title: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
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
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 9, top: 3),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 0.1),
    ),
  );

  Widget _settingCard({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blueAccent).withOpacity(0.13),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blueAccent, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.5),
          child: Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade800)),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
