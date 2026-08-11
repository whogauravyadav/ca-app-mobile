import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme.dart';

/// Soft animated backdrop used by auth screens.
class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEEF2FF),
                Color(0xFFF7F9FF),
                AppColors.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80 + 12 * math.sin(t),
                right: -60 + 10 * math.cos(t),
                child: _Blob(
                  size: 220,
                  color: AppColors.primary.withOpacity(0.35),
                ),
              ),
              Positioned(
                bottom: 80 + 14 * math.cos(t * 0.8),
                left: -70 + 8 * math.sin(t * 0.8),
                child: _Blob(
                  size: 180,
                  color: AppColors.primaryDark.withOpacity(0.18),
                ),
              ),
              Positioned(
                top: 180 + 10 * math.sin(t * 1.2),
                left: 40 + 6 * math.cos(t * 1.1),
                child: _Blob(
                  size: 90,
                  color: AppColors.accent.withOpacity(0.18),
                ),
              ),
              Positioned.fill(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    )
        .animate()
        .fadeIn(duration: 450.ms, delay: 180.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic, duration: 550.ms);
  }
}
