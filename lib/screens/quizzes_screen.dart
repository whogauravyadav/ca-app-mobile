import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/ad_banner_placeholder.dart';
import '../widgets/app_buttons.dart';
import '../widgets/notification_bell.dart';
import '../widgets/shimmer_list.dart';

class QuizzesScreen extends ConsumerStatefulWidget {
  const QuizzesScreen({super.key});

  @override
  ConsumerState<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends ConsumerState<QuizzesScreen> {
  List<QuizSummary> _quizzes = [];
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
      final quizzes = await ref.read(authServiceProvider).getQuizzes();
      if (!mounted) return;
      setState(() {
        _quizzes = quizzes;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quizzes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: const [NotificationBellButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(itemCount: 4),
              )
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(_error!, textAlign: TextAlign.center)),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: 160,
                          child: PrimaryButton(
                            label: 'Retry',
                            onPressed: _load,
                            icon: Icons.refresh_rounded,
                          ),
                        ),
                      ),
                    ],
                  )
                : _quizzes.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 56,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No quizzes yet',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Check back after the admin publishes practice sets.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _quizzes.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _quizzes.length) {
                            return const AdBannerPlaceholder(label: 'Quizzes');
                          }
                          final quiz = _quizzes[index];
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => context.push('/quiz/${quiz.id}'),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.quiz_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            quiz.title,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            [
                                              if (quiz.category != null)
                                                quiz.category!.name,
                                              if (quiz.questionsCount > 0)
                                                '${quiz.questionsCount} Qs',
                                              if (quiz.timeLimitSec != null)
                                                '${quiz.timeLimitSec! ~/ 60} min',
                                            ].where((e) => e.isNotEmpty).join(' · '),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (50 * index).ms)
                              .slideX(begin: 0.03, end: 0);
                        },
                      ),
      ),
    );
  }
}
