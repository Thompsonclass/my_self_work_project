import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';
import '../services/api_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xfff6f9fe),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 이름, 아이콘
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.11),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(
                    Icons.flag,
                    size: 56,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'OnePointUp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '나만의 목표 실천 도우미',
                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                ),
                const SizedBox(height: 24),

                // 로그인 카드
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            '로그인',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),

                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: '이메일',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value == null || value.isEmpty ? '이메일을 입력해주세요' : null,
                          ),
                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) => value == null || value.isEmpty ? '비밀번호를 입력해주세요' : null,
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();

                                  try {
                                    await authProvider.signIn(email, password);
                                    final goalExists = await ApiService.checkGoalExists(email);

                                    if (!context.mounted) return;
                                    if (goalExists) {
                                      // 목표가 있는 경우: GoalProvider에 email만 저장 (세부 목표는 improvement 화면에서 세션 API로 로딩)
                                      Provider.of<GoalProvider>(context, listen: false).setGoal(GoalModel(email: email));
                                      Navigator.pushReplacementNamed(context, '/improvement');
                                    } else {
                                      // 목표가 없는 경우: GoalProvider 초기화
                                      Provider.of<GoalProvider>(context, listen: false).clearGoal();
                                      Navigator.pushReplacementNamed(context, '/home');
                                    }


                                  } on FirebaseAuthException catch (e) {
                                    String errorMessage;
                                    switch (e.code) {
                                      case 'invalid-email':
                                        errorMessage = '잘못된 이메일 형식입니다.';
                                        break;
                                      case 'user-not-found':
                                        errorMessage = '존재하지 않는 계정입니다.';
                                        break;
                                      case 'wrong-password':
                                        errorMessage = '비밀번호가 틀렸습니다.';
                                        break;
                                      case 'user-disabled':
                                        errorMessage = '해당 계정은 비활성화되어 있습니다.';
                                        break;
                                      default:
                                        errorMessage = '로그인 중 알 수 없는 오류가 발생했습니다.';
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예기치 못한 오류 발생: $e')));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 필드를 입력해주세요.')));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('로그인'),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('아직 계정이 없으신가요?'),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/sign-up'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueAccent,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                child: const Text('회원가입'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
