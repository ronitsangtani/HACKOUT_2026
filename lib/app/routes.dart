import 'package:flutter/material.dart';
import '../features/activities/screens/activity_history_screen.dart';
import '../features/activities/screens/add_activity_screen.dart';
import '../features/activities/screens/carbon_impact_screen.dart';
import '../features/auth/screens/auth_wrapper_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/ranking/screens/leaderboard_screen.dart';
import '../features/recommendations/screens/recommendations_screen.dart';
import '../features/recommendations/screens/what_if_simulator_screen.dart';
import '../features/recycling/screens/recycling_locator_screen.dart';
import '../features/rewards/screens/rewards_screen.dart';
import 'main_navigation_scaffold.dart';

/// Centralized route definitions and generator for EcoLoop.
class AppRoutes {
  AppRoutes._();

  // Route path constants
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String addActivity = '/add-activity';
  static const String carbonImpact = '/carbon-impact';
  static const String activityHistory = '/activity-history';
  static const String recommendations = '/recommendations';
  static const String whatIf = '/what-if';
  static const String whatIfSimulator = whatIf;
  static const String recycling = '/recycling';
  static const String rewards = '/rewards';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String appSettings = '/settings';
  static const String settings = appSettings;

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapperScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScaffold(),
          settings: settings,
        );
      case addActivity:
        return MaterialPageRoute(
          builder: (_) => const AddActivityScreen(),
          settings: settings,
        );
      case carbonImpact:
        return MaterialPageRoute(
          builder: (_) => const CarbonImpactScreen(),
          settings: settings,
        );
      case activityHistory:
        return MaterialPageRoute(
          builder: (_) => const ActivityHistoryScreen(),
          settings: settings,
        );
      case recommendations:
        return MaterialPageRoute(
          builder: (_) => const RecommendationsScreen(),
          settings: settings,
        );
      case whatIf:
        return MaterialPageRoute(
          builder: (_) => const WhatIfSimulatorScreen(),
          settings: settings,
        );
      case recycling:
        return MaterialPageRoute(
          builder: (_) => const RecyclingLocatorScreen(),
          settings: settings,
        );
      case rewards:
        return MaterialPageRoute(
          builder: (_) => const RewardsScreen(),
          settings: settings,
        );
      case leaderboard:
        return MaterialPageRoute(
          builder: (_) => const LeaderboardScreen(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
