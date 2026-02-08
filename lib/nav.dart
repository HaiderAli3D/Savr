import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/scan_page.dart';
import 'screens/results_page.dart';
import 'screens/comparison_page.dart';
import 'screens/history_page.dart';
import 'screens/settings_page.dart';
import 'widgets/bottom_navigation.dart';

class AppRoutes {
  static const String home = '/';
  static const String results = '/results';
  static const String comparison = '/comparison';
  static const String history = '/history';
  static const String settings = '/settings';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const ScanPage(),
          ),
          GoRoute(
            path: AppRoutes.results,
            name: 'results',
            builder: (context, state) => const ResultsPage(),
          ),
          GoRoute(
            path: AppRoutes.comparison,
            name: 'comparison',
            builder: (context, state) => const ComparisonPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
