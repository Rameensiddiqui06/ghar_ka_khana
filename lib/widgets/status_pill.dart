import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});

  static const Map<String, List<dynamic>> _config = {
    'pending': [Color(0xFFFEF9EC), AppColors.warn, 'Pending'],
    'accepted': [Color(0xFFEDF7F1), AppColors.success, 'Accepted'],
    'preparing': [Color(0xFFFFF3EF), AppColors.primary, 'Preparing'],
    'ready': [Color(0xFFEDF7F1), AppColors.success, 'Ready'],
    'out-for-delivery': [Color(0xFFEDF7F1), AppColors.success, 'Out for Delivery'],
    'delivered': [Color(0xFFEDF7F1), AppColors.success, 'Delivered'],
    'cancelled': [Color(0xFFFDECEA), AppColors.error, 'Cancelled'],
  };

  @override
  Widget build(BuildContext context) {
    final config = _config[status] ?? [AppColors.sand, AppColors.muted, status];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: config[0] as Color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config[2] as String,
        style: TextStyle(
          color: config[1] as Color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}