import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const StarRow({super.key, required this.rating, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = (i + 1) <= rating.round();
        return Icon(
          Icons.star,
          size: size,
          color: filled ? AppColors.warn : AppColors.sand,
        );
      }),
    );
  }
}