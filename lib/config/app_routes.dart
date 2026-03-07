// lib/config/app_routes.dart

import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/timer/timer_screen.dart';
import '../screens/focus/focus_mode_screen.dart';
import '../screens/study_tube/study_tube_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/clock/clock_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String timer = '/timer';
  static const String focusMode = '/focus-mode';
  static const String studyTube = '/study-tube';
  static const String leaderboard = '/leaderboard';
  static const String clock = '/clock';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _buildPageRoute(
          const SplashScreen(),
          routeSettings,
        );
      case login:
        return _buildPageRoute(
          const LoginScreen(),
          routeSettings,
        );
      case register:
        return _buildPageRoute(
          const RegisterScreen(),
          routeSettings,
        );
      case home:
        return _buildPageRoute(
          const HomeScreen(),
          routeSettings,
        );
      case timer:
        return _buildPageRoute(
          const TimerScreen(),
          routeSettings,
        );
      case focusMode:
        return _buildPageRoute(
          const FocusModeScreen(),
          routeSettings,
        );
      case studyTube:
        return _buildPageRoute(
          const StudyTubeScreen(),
          routeSettings,
        );
      case leaderboard:
        return _buildPageRoute(
          const LeaderboardScreen(),
          routeSettings,
        );
      case clock:
        return _buildPageRoute(
          const ClockScreen(),
          routeSettings,
        );
      case profile:
        return _buildPageRoute(
          const ProfileScreen(),
          routeSettings,
        );
      case settings:
        return _buildPageRoute(
          const SettingsScreen(),
          routeSettings,
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'No route defined for ${routeSettings.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder<dynamic> _buildPageRoute(
    Widget page,
    RouteSettings routeSettings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: routeSettings,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return page;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        const Curve curve = Curves.easeInOutCubic;

        final Animation<double> fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final Animation<Offset> slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
