import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/primary_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final List<String> orderIds;
  final int total;
  final String methodLabel;
  final bool isOnline;

  const OrderSuccessScreen({
    super.key,
    required this.orderIds,
    required this.total,
    required this.methodLabel,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Order placed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  orderIds.map((e) => '#$e').join('  ·  '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isOnline
                      ? 'Your $methodLabel payment of Rs. $total will be verified by the seller using your TID. Once confirmed, they will accept and prepare your order.'
                      : 'Please keep Rs. $total ready. You will pay when your food arrives.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Back to Home',
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your order in the Orders tab.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
