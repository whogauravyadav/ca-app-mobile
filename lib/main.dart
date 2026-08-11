import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'services/api_client.dart';
import 'services/push_notification_service.dart';
import 'widgets/notification_bell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CurrentAffairsApp(),
    ),
  );
}

class CurrentAffairsApp extends ConsumerStatefulWidget {
  const CurrentAffairsApp({super.key});

  @override
  ConsumerState<CurrentAffairsApp> createState() => _CurrentAffairsAppState();
}

class _CurrentAffairsAppState extends ConsumerState<CurrentAffairsApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final push = ref.read(pushNotificationServiceProvider);
      await push.init();
      ref.read(unreadNotificationsProvider.notifier).refresh();
      push.onNotificationOpened.listen(_handlePushRoute);
    });
  }

  void _handlePushRoute(Map<String, dynamic> data) {
    final router = ref.read(goRouterProvider);
    final route = data['route']?.toString();
    if (route != null && route.isNotEmpty) {
      router.push(route);
      return;
    }
    final type = data['type']?.toString();
    if (type == 'article' && data['slug'] != null) {
      router.push('/article/${data['slug']}');
    } else if (type == 'quiz' && data['quiz_id'] != null) {
      router.push('/quiz/${data['quiz_id']}');
    } else {
      router.push('/notifications');
    }
    ref.read(unreadNotificationsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated ||
          next.status == AuthStatus.guest) {
        ref.read(pushNotificationServiceProvider).syncToken();
        ref.read(unreadNotificationsProvider.notifier).refresh();
      }
    });

    return MaterialApp.router(
      title: 'Daily Current Affairs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
