import 'package:error404project/mobile/views/WelcomePage.dart';
import 'package:error404project/mobile/views/WorkSchedulePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Để sử dụng kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import các trang Mobile và Web
import '../../mobile/views/CompleteProfilePage.dart';
import '../../mobile/views/HomePage.dart';
import '../../mobile/views/LoginPage.dart';
import '../../mobile/views/NotificationPage.dart';
import '../../mobile/views/ManagePage.dart';
import '../../mobile/views/RegisPage.dart';
import '../../mobile/views/TaskPage.dart';
import '../../web/views/Home.dart';
import '../../web/views/WebLogin.dart';
import '../../web/views/WebRegister.dart';
import '../widgets/BottomNavBarWidget.dart';
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return '/home';
    }
    return null;
  },
  routes: [
    // Route mặc định: kiểm tra người dùng đã đăng nhập hay chưa
    GoRoute(
      path: '/',
      builder: (context, state) {
        return kIsWeb ? const WebLogin() : const WelcomePage();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return kIsWeb ? const WebLogin() : const LoginPage();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return kIsWeb ? const WebRegister() : const RegisterPage();
      },
    ),
    GoRoute(
        path: '/work-schedule',
        builder: (context, state) {
          return WorkSchedulePage();
          },
    ),
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
    ShellRoute(
      builder: (context, state, child) {
        int currentIndex = _getIndexFromPath(state.uri.toString());
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavBarWidget(currentIndex: currentIndex),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/tasks', builder: (context, state) => const TaskPage()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationPage()),
        GoRoute(path: '/manage', builder: (context, state) => const ManagePage()),
      ],
    ),
  ],
);

int _getIndexFromPath(String path) {
  switch (path) {
    case '/home':
      return 0;
    case '/tasks':
      return 1;
    case '/notifications':
      return 2;
    case '/manage':
      return 3;
    default:
      return 0;
  }
}