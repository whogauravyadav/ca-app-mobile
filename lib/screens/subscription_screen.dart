import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../widgets/app_buttons.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/shimmer_list.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  List<PlanModel> _plans = [];
  bool _loading = true;
  String? _error;
  int? _activatingId;

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
      final plans = await ref.read(authServiceProvider).getPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  Future<void> _activate(PlanModel plan) async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to activate a subscription')),
      );
      context.push('/login');
      return;
    }

    setState(() => _activatingId = plan.id);
    try {
      final user =
          await ref.read(authServiceProvider).activateSubscription(plan.id);
      ref.read(authProvider.notifier).updateUser(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plan.name} activated (test mode)')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _activatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdFree = ref.watch(authProvider).isAdFree;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Go Ad-Free',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 3),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdFree
                                ? 'You are ad-free'
                                : 'Study without interruptions',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Remove banners, unlock premium early CA, and support the product.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 20),
                    if (_plans.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No plans available yet. Ask an admin to create subscription plans.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ..._plans.asMap().entries.map((entry) {
                        final i = entry.key;
                        final plan = entry.value;
                        final activating = _activatingId == plan.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plan.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${plan.priceInr}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${plan.durationDays} days',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (plan.features.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    ...plan.features.map(
                                      (f) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(f)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  FilledButton(
                                    onPressed:
                                        activating ? null : () => _activate(plan),
                                    child: activating
                                        ? const ButtonLoader()
                                        : Text(
                                            isAdFree
                                                ? 'Extend with ${plan.name}'
                                                : 'Subscribe (test)',
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (80 * i).ms)
                              .slideY(begin: 0.04, end: 0),
                        );
                      }),
                    const SizedBox(height: 8),
                    Text(
                      'Phase 1 uses a stub activate API — no real payment is charged. Restore purchases will arrive in Phase 2.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Restore purchases — coming in Phase 2',
                            ),
                          ),
                        );
                      },
                      child: const Text('Restore purchases'),
                    ),
                  ],
                ),
    );
  }
}
