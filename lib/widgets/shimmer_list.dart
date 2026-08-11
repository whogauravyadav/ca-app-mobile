import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF5),
      highlightColor: const Color(0xFFF7F9FC),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 12),
            child: Container(
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerHeroCard extends StatelessWidget {
  const ShimmerHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF5),
      highlightColor: const Color(0xFFF7F9FC),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
