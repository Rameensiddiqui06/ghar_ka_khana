import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class AppLogo extends StatelessWidget {
  final bool light;

  const AppLogo({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : AppColors.text;
    final subColor = light
        ? Colors.white.withValues(alpha: 0.65)
        : AppColors.text2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text('🏠', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GHAR KA KHANA',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'From Their Kitchen to Your Table.',
              style: TextStyle(
                color: subColor,
                fontSize: 10,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}