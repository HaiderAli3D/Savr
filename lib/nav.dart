import 'package:go_router/go_router.dart';
import 'screens/scan_page.dart';
import 'screens/preferences_page.dart';
import 'screens/summary_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String preferences = '/preferences';
  static const String summary = '/summary';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const ScanReceiptPage(),
      ),
      GoRoute(
        path: AppRoutes.preferences,
        name: 'preferences',
        builder: (context, state) => const PreferencesPage(),
      ),
      GoRoute(
        path: AppRoutes.summary,
        name: 'summary',
        builder: (context, state) => const SummaryPage(),
      ),
    ],
  );
}
