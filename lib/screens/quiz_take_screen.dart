import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/ad_banner_placeholder.dart';
import '../widgets/app_buttons.dart';

class QuizTakeScreen extends ConsumerStatefulWidget {
  const QuizTakeScreen({super.key, required this.quizId});

  final int quizId;

  @override
  ConsumerState<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends ConsumerState<QuizTakeScreen> {
  QuizDetail? _quiz;
  bool _loading = true;
  String? _error;
  int _index = 0;
  final Map<int, int?> _answers = {};
  bool _submitting = false;
  QuizResult? _result;
  Timer? _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quiz = await ref.read(authServiceProvider).getQuiz(widget.quizId);
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _loading = false;
        _remaining = quiz.timeLimitSec ?? 0;
      });
      if (_remaining > 0) {
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) return;
          if (_remaining <= 1) {
            t.cancel();
            _submit();
          } else {
            setState(() => _remaining--);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting || _result != null) return;
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to submit and save your score')),
      );
      return;
    }
    final quiz = _quiz;
    if (quiz == null) return;

    setState(() => _submitting = true);
    _timer?.cancel();
    try {
      final payload = quiz.questions
          .map((q) => {
                'question_id': q.id,
                'selected_index': _answers[q.id],
              })
          .toList();
      final result =
          await ref.read(authServiceProvider).submitQuiz(quiz.id, payload);
      if (!mounted) return;
      setState(() {
        _result = result;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: AppLoader(message: 'Loading quiz...'),
      );
    }
    if (_error != null || _quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Quiz not found'),
              const SizedBox(height: 12),
              SizedBox(width: 160, child: PrimaryButton(label: 'Retry', onPressed: _load, icon: Icons.refresh_rounded)),
            ],
          ),
        ),
      );
    }

    if (_result != null) {
      return _QuizResultView(
        quizTitle: _quiz!.title,
        result: _result!,
        onDone: () => context.pop(),
        onRetry: () {
          setState(() {
            _result = null;
            _index = 0;
            _answers.clear();
          });
          _load();
        },
      );
    }

    final quiz = _quiz!;
    final question = quiz.questions[_index];
    final theme = Theme.of(context);
    final progress = ( _index + 1) / quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_remaining > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _remaining < 30
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${_index + 1} of ${quiz.questions.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.question,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ).animate().fadeIn(duration: 250.ms),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: question.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final selected = _answers[question.id] == i;
                        return Material(
                          color: selected
                              ? theme.colorScheme.primary.withOpacity(0.12)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(
                              () => _answers[question.id] = i,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(question.options[i])),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      if (_index > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _index--),
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_index > 0) const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submitting
                              ? null
                              : () {
                                  if (_index < quiz.questions.length - 1) {
                                    setState(() => _index++);
                                  } else {
                                    _submit();
                                  }
                                },
                          child: _submitting
                              ? const ButtonLoader()
                              : Text(
                                  _index < quiz.questions.length - 1
                                      ? 'Next'
                                      : 'Submit',
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.quizTitle,
    required this.result,
    required this.onDone,
    required this.onRetry,
  });

  final String quizTitle;
  final QuizResult result;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final great = result.percent >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: great
                      ? [AppColors.primary, const Color(0xFF5C6BC0)]
                      : [
                          theme.colorScheme.outline,
                          theme.colorScheme.outlineVariant,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.35),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${result.percent}%',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1200.ms, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(
              great ? 'Great job!' : 'Keep practicing',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'You scored ${result.score} / ${result.total} on "$quizTitle"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            const AdBannerPlaceholder(label: 'Quiz result'),
            const Spacer(),
            FilledButton(
              onPressed: onDone,
              child: const Text('Done'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/subscription'),
              child: const Text('Go Ad-Free'),
            ),
          ],
        ),
      ),
    );
  }
}
