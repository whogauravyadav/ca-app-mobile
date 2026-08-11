import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_config.dart';
import '../providers/auth_provider.dart';
import '../screens/article_detail_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/onboarding_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quiz_take_screen.dart';
import '../screens/quizzes_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/subscription_screen.dart';
import '../services/api_client.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onboardingDone = prefs.getBool(AppConfig.onboardingKey) ?? false;
      final isSplash = loc == '/splash';
      final isOnboarding = loc == '/onboarding';
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (isSplash) return null;
      if (auth.status == AuthStatus.unknown) return null;

      if (!onboardingDone && !isOnboarding) {
        return '/onboarding';
      }

      if (onboardingDone && isOnboarding) {
        return auth.status == AuthStatus.authenticated ||
                auth.status == AuthStatus.guest
            ? '/home'
            : '/login';
      }

      final loggedIn = auth.status == AuthStatus.authenticated ||
          auth.status == AuthStatus.guest;

      if (!loggedIn && !isAuthRoute && !isOnboarding) {
        return '/login';
      }

      if (loggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/quizzes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuizzesScreen(),
            ),
          ),
          GoRoute(
            path: '/bookmarks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookmarksScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/article/:slug',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ArticleDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/quiz/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuizTakeScreen(
          quizId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/subscription',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
