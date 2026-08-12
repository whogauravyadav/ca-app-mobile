import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_shell.dart';
import '../widgets/exam_multi_select.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  List<String> _exams = [];
  String? _examsError;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _shake = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _triggerShake() {
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _shake = false);
    });
  }

  bool _validateExtras() {
    if (_exams.isEmpty) {
      setState(() => _examsError = 'Select at least one exam');
      return false;
    }
    setState(() => _examsError = null);
    return true;
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    final extrasOk = _validateExtras();
    if (!formOk || !extrasOk) {
      _triggerShake();
      return;
    }
    setState(() => _loading = true);
    ref.read(authProvider.notifier).clearError();
    final ok = await ref.read(authProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          exams: _exams,
          password: _password.text,
          passwordConfirmation: _confirm.text,
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.textPrimary,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.2, end: 0),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AppLogo(height: 140, width: 260, showShadow: false)
                              .animate()
                              .fadeIn(duration: 450.ms)
                              .scale(
                                begin: const Offset(0.88, 0.88),
                                end: const Offset(1, 1),
                                curve: Curves.easeOutBack,
                                duration: 600.ms,
                              ),
                          const SizedBox(height: 14),
                          Text(
                            'Create account',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 100.ms)
                              .slideY(begin: 0.12, end: 0, delay: 100.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Tell us your phone & target exams to personalize prep.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              height: 1.45,
                              fontSize: 14,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 180.ms),
                          const SizedBox(height: 22),
                          AuthCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _name,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Full name',
                                      prefixIcon:
                                          Icon(Icons.person_outline_rounded),
                                    ),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Name required'
                                            : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon:
                                          Icon(Icons.mail_outline_rounded),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _phone,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Phone number',
                                      hintText: '10-digit mobile',
                                      prefixIcon:
                                          Icon(Icons.phone_outlined),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Phone is required';
                                      }
                                      if (!RegExp(r'^[6-9]\d{9}$')
                                          .hasMatch(v.trim())) {
                                        return 'Enter a valid 10-digit Indian mobile';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  ExamMultiSelectField(
                                    selectedKeys: _exams,
                                    errorText: _examsError,
                                    onChanged: (keys) => setState(() {
                                      _exams = keys;
                                      _examsError = keys.isEmpty
                                          ? 'Select at least one exam'
                                          : null;
                                    }),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: _obscure,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.length < 6) {
                                        return 'Min 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _confirm,
                                    obscureText: _obscureConfirm,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      labelText: 'Confirm password',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v != _password.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            )
                                .animate(target: _shake ? 1 : 0)
                                .shake(
                                  hz: 4,
                                  duration: 400.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                          const SizedBox(height: 22),
                          PrimaryButton(
                            label: 'Create account',
                            loading: _loading,
                            onPressed: _submit,
                            icon: Icons.person_add_alt_1_rounded,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Already have an account? Sign in',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
