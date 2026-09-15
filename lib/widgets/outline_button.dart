import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool danger;
  final bool full;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.danger = false,
    this.full = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.error
        : AppColors.primary;

    return SizedBox(
      width: full ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: color,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}