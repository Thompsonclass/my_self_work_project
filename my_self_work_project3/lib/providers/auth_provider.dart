import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import 'goal_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 현재 로그인한 사용자 반환
  User? get currentUser => _firebaseAuth.currentUser;

  // 회원가입 함수
  Future<void> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw '비밀번호가 너무 약합니다. 더 복잡한 비밀번호를 사용해주세요.';
        case 'email-already-in-use':
          throw '이미 사용 중인 이메일입니다.';
        case 'invalid-email':
          throw '유효하지 않은 이메일 형식입니다.';
        case 'operation-not-allowed':
          throw '이메일 회원가입이 현재 비활성화되어 있습니다.';
        default:
          throw '회원가입 중 오류가 발생했습니다: ${e.message}';
      }
    } catch (e) {
      throw '회원가입 요청 중 예기치 못한 오류가 발생했습니다.';
    }
  }

  // 로그인 함수
  Future<void> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        notifyListeners();
      } else {
        throw '로그인에 실패했습니다. 다시 시도해주세요.';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw '해당 이메일로 가입된 계정을 찾을 수 없습니다.';
        case 'wrong-password':
          throw '비밀번호가 틀렸습니다.';
        case 'invalid-email':
          throw '유효하지 않은 이메일 형식입니다.';
        case 'user-disabled':
          throw '해당 계정은 비활성화되어 있습니다.';
        default:
          throw '로그인 중 오류가 발생했습니다: ${e.message}';
      }
    } catch (e) {
      throw '로그인 요청 중 예기치 못한 오류가 발생했습니다.';
    }
  }

  // 로그아웃 함수
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }


}
