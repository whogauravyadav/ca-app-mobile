import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// Reusable brand logo for splash, auth, home app bar, and empty states.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 160,
    this.width,
    this.showShadow = true,
  });

  final double height;
  final double? width;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppConfig.logoAsset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.menu_book_rounded,
        size: height * 0.45,
        color: const Color(0xFF6B86F0),
      ),
    );

    if (!showShadow) return image;

    return Container(
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
    );
  }
}
