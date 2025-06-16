import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final nickname = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Firebase 인증 사용자를 불러올 수 없습니다.');

      await user.updateDisplayName(nickname);

      final uid = user.uid;
      String provider;
      try {
        provider = user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'password';
      } catch (_) {
        provider = 'password';
      }

      await ApiService.signUpUser(
        nickname: nickname,
        email: email,
        uid: uid,
        provider: provider,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다!')),
      );
      Navigator.of(context).pushNamed('/sign-in');

    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'email-already-in-use' => '이미 사용 중인 이메일입니다.',
        'invalid-email' => '유효하지 않은 이메일 형식입니다.',
        'operation-not-allowed' => '이메일 가입이 현재 허용되지 않습니다.',
        'weak-password' => '비밀번호가 너무 약합니다. 더 복잡한 비밀번호를 사용해주세요.',
        _ => 'Firebase 오류 발생: ${e.message}'
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 처리 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f9fe),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 타이틀/아이콘
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.11),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '회원가입',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 8),
                const Text(
                  '원포인트업 계정을 만들어보세요!',
                  style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                ),
                const SizedBox(height: 16),

                // 카드로 폼 감싸기
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 닉네임
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: '닉네임',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (value) => value == null || value.isEmpty ? '닉네임을 입력해주세요' : null,
                          ),
                          const SizedBox(height: 16),
                          // 이메일
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
                          const SizedBox(height: 16),
                          // 비밀번호
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) => value == null || value.isEmpty ? '비밀번호를 입력해주세요' : null,
                          ),
                          const SizedBox(height: 16),
                          // 비밀번호 확인
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: '비밀번호 확인',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호 확인이 필요합니다';
                              }
                              if (value != _passwordController.text) {
                                return '비밀번호가 일치하지 않습니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _handleSignUp,
                              child: const Text('회원가입'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('이미 계정이 있으신가요?'),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueAccent,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                child: const Text('로그인'),
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
