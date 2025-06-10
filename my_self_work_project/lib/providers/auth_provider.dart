import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 회원가입 함수
  Future<void> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // 상태 변경 알림
    } on FirebaseAuthException catch (e) {
      // Firebase Auth 관련 오류 처리
      if (e.code == 'weak-password') {
        throw ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw ('The account already exists for that email.');
      }
    } catch (e) {
      throw (e.toString()); // 일반 오류 처리
    }
  }

  // 로그인 함수
  Future<void> signIn(String email, String password) async {
    try {
      // 이메일과 비밀번호로 Firebase Auth 로그인 시도
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 로그인 성공 시 사용자 정보를 확인
      if (userCredential.user != null) {
        notifyListeners(); // 로그인 성공 후 상태 알림
      } else {
        throw ('Failed to sign in.');
      }
    } on FirebaseAuthException catch (e) {
      // 로그인 관련 오류 처리
      if (e.code == 'user-not-found') {
        throw ('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw ('Wrong password provided.');
      } else {
        throw ('Error: ${e.message}'); // 기타 Firebase Auth 오류 처리
      }
    } catch (e) {
      throw ('Error: $e'); // 일반 오류 처리
    }
  }

  // 로그아웃 함수
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }

  // 현재 로그인한 사용자를 가져오는 함수
  User? get currentUser {
    return _firebaseAuth.currentUser;
  }
}
