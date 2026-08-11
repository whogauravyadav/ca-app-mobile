import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/notification_bell.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotificationModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(authServiceProvider).getNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
      ref.read(unreadNotificationsProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  Future<void> _open(AppNotificationModel n) async {
    final auth = ref.read(authProvider);
    if (auth.status == AuthStatus.authenticated && !n.isRead) {
      try {
        await ref.read(authServiceProvider).markNotificationRead(n.id);
        setState(() {
          _items = _items
              .map((e) => e.id == n.id ? e.copyWith(isRead: true) : e)
              .toList();
        });
        ref.read(unreadNotificationsProvider.notifier).refresh();
      } catch (_) {}
    }

    final route = n.route;
    if (route != null && mounted) {
      context.push(route);
    }
  }

  Future<void> _markAll() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    try {
      await ref.read(authServiceProvider).markAllNotificationsRead();
      setState(() {
        _items = _items.map((e) => e.copyWith(isRead: true)).toList();
      });
      ref.read(unreadNotificationsProvider.notifier).clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'article':
        return Icons.article_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth =
        ref.watch(authProvider).status == AuthStatus.authenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (isAuth && _items.any((e) => !e.isRead))
            TextButton(
              onPressed: _markAll,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const AppLoader(message: 'Loading notifications…')
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.cloud_off_rounded,
                          size: 48, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Center(
                        child: FilledButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  )
                : _items.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You’ll see updates when new articles or quizzes go live.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final n = _items[i];
                          final time = n.createdAt != null
                              ? DateFormat('dd MMM, hh:mm a').format(
                                  DateTime.tryParse(n.createdAt!)?.toLocal() ??
                                      DateTime.now(),
                                )
                              : '';
                          return Material(
                            color: n.isRead
                                ? Colors.white
                                : AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _open(n),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _iconFor(n.type),
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            n.body,
                                            style: GoogleFonts.inter(
                                              color: AppColors.textSecondary,
                                              height: 1.35,
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (time.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              time,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 6),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryDark,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                              .slideY(begin: 0.04, end: 0, delay: (40 * i).ms);
                        },
                      ),
      ),
    );
  }
}
