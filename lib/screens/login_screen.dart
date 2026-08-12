import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'student@currentaffairs.app');
  final _password = TextEditingController(text: 'password');
  bool _obscure = true;
  bool _loading = false;
  bool _shake = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _triggerShake() {
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _shake = false);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }
    setState(() => _loading = true);
    ref.read(authProvider.notifier).clearError();
    final ok = await ref.read(authProvider.notifier).login(
          _email.text.trim(),
          _password.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.go('/home');
    } else {
      _triggerShake();
      final err = ref.read(authProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(height: 160, width: 280, showShadow: false)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.86, 0.86),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 650.ms,
                        ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 120.ms, duration: 400.ms)
                        .slideY(begin: 0.15, end: 0, delay: 120.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to sync bookmarks, streaks & quiz history.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        height: 1.45,
                        fontSize: 14,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 28),
                    AuthCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(delay: 280.ms)
                                .slideX(begin: -0.04, end: 0, delay: 280.ms),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(delay: 360.ms)
                                .slideX(begin: 0.04, end: 0, delay: 360.ms),
                          ],
                        ),
                      )
                          .animate(target: _shake ? 1 : 0)
                          .shake(hz: 4, duration: 400.ms, curve: Curves.easeInOut),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Sign In',
                      loading: _loading,
                      onPressed: _submit,
                      icon: Icons.login_rounded,
                    )
                        .animate()
                        .fadeIn(delay: 420.ms)
                        .slideY(begin: 0.12, end: 0, delay: 420.ms),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Create account',
                      onPressed: () => context.push('/register'),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).continueAsGuest();
                        context.go('/home');
                      },
                      child: Text(
                        'Continue as guest',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 560.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
