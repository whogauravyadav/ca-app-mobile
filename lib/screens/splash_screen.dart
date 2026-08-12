import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_config.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../widgets/app_logo.dart';

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
      Future<void>.delayed(const Duration(milliseconds: 2400)),
      _waitAuthReady(),
    ]);
    if (!mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final onboardingDone = prefs.getBool(AppConfig.onboardingKey) ?? false;
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
    for (var i = 0; i < 20; i++) {
      final status = ref.read(authProvider).status;
      if (status != AuthStatus.unknown) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Center(
                child: const AppLogo(height: 220, showShadow: false)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.88, 0.88),
                      end: const Offset(1, 1),
                      duration: 900.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
              const Spacer(flex: 2),
              Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
