import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Sử dụng GoRouter

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng ký người dùng với email và mật khẩu
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Email đã tồn tại");
        return null;
      } else {
        print("Error during sign up: $e");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Đăng nhập người dùng với email và mật khẩu
  Future<User?> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Điều hướng tới trang Home sau khi đăng nhập
      context.go('/home');
      return credential.user;
    } catch (e) {
      print("Error during sign in: $e");
    }
    return null;
  }

  // Đăng xuất người dùng và điều hướng đến trang Login
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    context.go('/login'); // Quay lại trang đăng nhập
  }
}
