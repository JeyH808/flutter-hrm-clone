import 'package:error404project/mobile/views/WelcomePage.dart';
import 'package:flutter/foundation.dart'; // Để sử dụng kIsWeb
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import các trang Mobile và Web
import '../../mobile/views/CompleteProfilePage.dart';
import '../../mobile/views/HomePage.dart';
import '../../mobile/views/LoginPage.dart';
import '../../mobile/views/RegisPage.dart';
import '../../web/views/Home.dart';
import '../../web/views/WebLogin.dart';
import '../../web/views/WebRegister.dart';
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Route mặc định: kiểm tra người dùng đã đăng nhập hay chưa
    GoRoute(
      path: '/',
      builder: (context, state) {
        return kIsWeb ? const WebLogin() : const WelcomePage();
      },
    ),
    // Trang đăng nhập
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return kIsWeb ? const WebLogin() : const LoginPage();
      },
    ),
    // Trang đăng ký
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return kIsWeb ? const WebRegister() : const RegisterPage();
      },
    ),
    // Trang Home (sau khi đăng nhập)
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return kIsWeb ? const WebHome() : const HomePage();
      },
    ),
    // Trang hoàn thiện thông tin
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfilePage(),
    ),
  ],
);
