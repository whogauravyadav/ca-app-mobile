import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// Reusable brand logo for splash, auth, and empty states.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 160,
    this.showShadow = true,
  });

  final double height;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppConfig.logoAsset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.menu_book_rounded,
        size: height * 0.45,
        color: const Color(0xFF6B86F0),
      ),
    );

    if (!showShadow) return Center(child: image);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B86F0).withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: image,
      ),
    );
  }
}
