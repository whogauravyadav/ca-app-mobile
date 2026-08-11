import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';

/// Banner / native ad placeholder shown only when the user is NOT ad-free.
class AdBannerPlaceholder extends ConsumerWidget {
  const AdBannerPlaceholder({
    super.key,
    this.label = 'Sponsored',
    this.height = 56,
  });

  final String label;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdFree = ref.watch(authProvider).isAdFree;
    if (isAdFree) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.6),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.campaign_outlined,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ad placeholder · $label',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/subscription'),
            child: Text(
              'Remove ads',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdNativePlaceholder extends ConsumerWidget {
  const AdNativePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdFree = ref.watch(authProvider).isAdFree;
    if (isAdFree) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NATIVE AD',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade to go ad-free and unlock a cleaner reading experience.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: () => context.push('/subscription'),
              child: const Text('Go Ad-Free'),
            ),
          ),
        ],
      ),
    );
  }
}
