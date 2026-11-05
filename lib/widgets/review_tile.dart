import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/review.dart';
import 'star_row.dart';

String _ago(DateTime? d) {
  if (d == null) return 'Just now';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 30) {
    final w = diff.inDays ~/ 7;
    return '$w week${w == 1 ? '' : 's'} ago';
  }
  final m = diff.inDays ~/ 30;
  return '$m month${m == 1 ? '' : 's'} ago';
}

class ReviewTile extends StatelessWidget {
  final Review review;
  final bool showDish; // show the dish name (useful on the seller screen)
  final VoidCallback? onReply; // non-null => shows a Reply button (seller)

  const ReviewTile({
    super.key,
    required this.review,
    this.showDish = false,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.customerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                _ago(review.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          if (showDish && review.foodName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              review.foodName,
              style: const TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 4),
          StarRow(rating: review.rating, size: 11),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.text2,
                height: 1.4,
              ),
            ),
          ],
          if (review.sellerReply != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seller reply',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.sellerReply!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onReply != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onReply,
                child: Text(
                  review.sellerReply == null ? 'Reply' : 'Edit reply',
                ),
              ),
            ),
        ],
      ),
    );
  }
}