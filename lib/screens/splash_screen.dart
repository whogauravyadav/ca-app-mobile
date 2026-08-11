import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/api_config.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 2200)),
      _waitAuthReady(),
    ]);
    if (!mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final onboardingDone = prefs.getBool(ApiConfig.onboardingKey) ?? false;
    final auth = ref.read(authProvider);

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    if (auth.status == AuthStatus.authenticated ||
        auth.status == AuthStatus.guest) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  Future<void> _waitAuthReady() async {
    // Give auth bootstrap a moment; splash already waits 2.2s
    for (var i = 0; i < 20; i++) {
      final status = ref.read(authProvider).status;
      if (status != AuthStatus.unknown) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              Color(0xFF5C6BC0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              _AnimatedLogo(),
              const SizedBox(height: 28),
              Text(
                'Current Affairs',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Exam-ready daily updates',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
              const Spacer(flex: 4),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accent.withOpacity(0.9),
                ),
              ).animate().fadeIn(delay: 900.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.35),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        size: 52,
        color: Colors.white,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.05, 1.05),
          duration: 1400.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .shimmer(
          delay: 200.ms,
          duration: 1600.ms,
          color: AppColors.accent.withOpacity(0.4),
        );
  }
}
