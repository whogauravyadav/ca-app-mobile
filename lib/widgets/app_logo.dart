import 'package:flutter/material.dart';

import '../core/app_config.dart';

/// Brand logo. Always uses [BoxFit.contain] so the full artwork is visible.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 160,
    this.width,
    this.showShadow = false,
    this.asset,
  });

  final double height;
  final double? width;
  final bool showShadow;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset ?? AppConfig.logoAsset,
      height: height,
      width: width ?? height,
      fit: BoxFit.contain,
      alignment: Alignment.center,
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
