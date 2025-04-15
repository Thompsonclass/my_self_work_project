import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // AuthProvider import

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 관리하는 키
  bool _isPasswordVisible = false; // 비밀번호 가시성 상태 변수
  bool _isConfirmPasswordVisible = false; // 비밀번호 확인 가시성 상태 변수

  final _usernameController = TextEditingController(); // 사용자 이름 컨트롤러
  final _passwordController = TextEditingController(); // 비밀번호 컨트롤러
  final _confirmPasswordController = TextEditingController(); // 비밀번호 확인 컨트롤러
  final _emailController = TextEditingController(); // 이메일 컨트롤러

  @override
  void dispose() {
    // 컨트롤러 메모리 해제
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider 인스턴스 가져오기

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // 폼 키 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                children: [
                  // 사용자 이름 입력 필드
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username'; // 빈 값 검사
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // 비밀번호 입력 필드
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // 비밀번호 가시성 토글
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible, // 비밀번호 숨김 설정
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password'; // 빈 값 검사
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // 비밀번호 확인 입력 필드
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible; // 비밀번호 확인 가시성 토글
                          });
                        },
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible, // 비밀번호 확인 숨김 설정
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password'; // 빈 값 검사
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match'; // 비밀번호 일치 검사
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // 이메일 주소 입력 필드
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'E-mail address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address'; // 빈 값 검사
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // 회원가입 버튼
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // 모든 필드가 유효한지 검사
                        final email = _emailController.text;
                        final password = _passwordController.text;

                        try {
                          await authProvider.signUp(email, password); // 회원가입 시도
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign up successful!')),
                          );
                          Navigator.pushReplacementNamed(context, '/sign-in'); // 로그인 화면으로 이동
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error signing up: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all fields correctly')), // 필드가 잘못된 경우 경고 메시지
                        );
                      }
                    },
                    child: const Text('Sign Up'),
                  ),
                  SizedBox(height: 16),

                  // 로그인 페이지로 이동하는 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign-in'); // 로그인 페이지로 이동
                        },
                        child: Text('Sign In'),
                      ),
                    ],
                  ),
                ],

              ),
            ),
          ),
        ),
      ),
    );
  }
}
