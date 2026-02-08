import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/scan_page.dart';
import 'screens/camera_page.dart';
import 'screens/preferences_page.dart';
import 'screens/results_page.dart';
import 'screens/history_page.dart';
import 'screens/settings_page.dart';
import 'screens/summary_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String preferences = '/preferences';
  static const String results = '/results';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String summary = '/summary';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const ScanReceiptPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.camera,
        name: 'camera',
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: AppRoutes.preferences,
        name: 'preferences',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const PreferencesPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const ResultsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const HistoryPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.summary,
        name: 'summary',
        builder: (context, state) => const SummaryPage(),
      ),
    ],
  );
}
