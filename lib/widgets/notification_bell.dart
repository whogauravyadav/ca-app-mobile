import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

final unreadNotificationsProvider =
    StateNotifierProvider<UnreadNotificationsNotifier, int>((ref) {
  return UnreadNotificationsNotifier(ref.watch(authServiceProvider));
});

class UnreadNotificationsNotifier extends StateNotifier<int> {
  UnreadNotificationsNotifier(this._auth) : super(0) {
    refresh();
  }

  final AuthService _auth;

  Future<void> refresh() async {
    try {
      final count = await _auth.getUnreadNotificationCount();
      state = count;
    } catch (_) {
      // Keep last known count
    }
  }

  void set(int value) => state = value;

  void clear() => state = 0;
}

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider);

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () async {
        await context.push('/notifications');
        ref.read(unreadNotificationsProvider.notifier).refresh();
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: AppColors.danger,
        label: Text(
          unread > 99 ? '99+' : '$unread',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Convenience helper for screens that need a quick refresh after resume.
Future<void> refreshUnread(WidgetRef ref) {
  return ref.read(unreadNotificationsProvider.notifier).refresh();
}

String apiErrorOr(Object e, [String fallback = 'Something went wrong']) {
  return apiErrorMessage(e).isNotEmpty ? apiErrorMessage(e) : fallback;
}
