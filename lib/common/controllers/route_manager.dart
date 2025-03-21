import 'package:error404project/mobile/views/WelcomePage.dart';
import 'package:flutter/foundation.dart'; // Để sử dụng kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import các trang Mobile và Web
import '../../mobile/views/CompleteProfilePage.dart';
import '../../mobile/views/HomePage.dart';
import '../../mobile/views/LoginPage.dart';
import '../../mobile/views/NotificationPage.dart';
import '../../mobile/views/ProfilePage.dart';
import '../../mobile/views/RegisPage.dart';
import '../../mobile/views/TaskPage.dart';
import '../../web/views/Home.dart';
import '../../web/views/WebLogin.dart';
import '../../web/views/WebRegister.dart';
import '../widgets/BottomNavBarWidget.dart';
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
        GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
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
    case '/profile':
      return 3;
    default:
      return 0;
  }
}