
import 'package:flutter/material.dart';
import 'package:focus_app/ui/screens/splash_screen.dart';
import 'package:focus_app/ui/screens/main_navigation_screen.dart';
import 'package:focus_app/ui/screens/timer_screen.dart';
import 'package:focus_app/ui/screens/focus_mode_screen.dart';
import 'package:focus_app/ui/screens/study_tube_screen.dart';
import 'package:focus_app/ui/screens/leaderboard_screen.dart';
import 'package:focus_app/ui/screens/clock_screen.dart';
import 'package:focus_app/ui/screens/profile_screen.dart';
import 'package:focus_app/ui/screens/settings_screen.dart';
import 'package:focus_app/ui/screens/dashboard_screen.dart';
import 'app_constants.dart';

class AppRoutes {
  AppRoutes._();

  // --- Route Names ---
  static const String splash = '/';
  static const String main = '/main'; // Changed from home to main
  static const String timer = '/timer';
  static const String focusMode = '/focus-mode';
  static const String studyTube = '/study-tube';
  static const String leaderboard = '/leaderboard';
  static const String clock = '/clock';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // --- Route Generator ---
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _buildPageRoute(
          const SplashScreen(),
          routeSettings,
        );

      case main:
        return _buildPageRoute(
          const MainNavigationScreen(),
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
        return _buildPageRoute(
          const Scaffold(
            backgroundColor: Color(0xFF000000),
            body: Center(
              child: Text(
                'Route not found',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          routeSettings,
        );
    }
  }

  // --- Premium Page Transition ---
  static PageRouteBuilder<dynamic> _buildPageRoute(
    Widget page,
    RouteSettings routeSettings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: routeSettings,
      transitionDuration: Duration(
        milliseconds: AppConstants.pageTransitionMs,
      ),
      reverseTransitionDuration: Duration(
        milliseconds: AppConstants.pageTransitionMs,
      ),
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
