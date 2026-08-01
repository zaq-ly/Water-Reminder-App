import 'package:go_router/go_router.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/settings/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
