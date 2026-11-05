import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/star_row.dart';

class SellerReviewsScreen extends StatelessWidget {
  const SellerReviewsScreen({super.key});

  Future<void> _reply(BuildContext context, Review r) async {
    final ctrl = TextEditingController(text: r.sellerReply ?? '');
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to ${r.customerName}'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          maxLength: 300,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Write a reply…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Post'),
          ),
        ],
      ),
    );
    if (text == null) return;
    try {
      await ReviewService().reply(r.id, text);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not post reply: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<Review>>(
              stream: ReviewService().streamForSeller(uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reviews = snap.data!;
                if (reviews.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                final avg = reviews.fold<double>(0, (a, r) => a + r.rating) /
                    reviews.length;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Text(
                          avg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 10),
                        StarRow(rating: avg, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${reviews.length} reviews',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...reviews.map(
                      (r) => ReviewTile(
                        review: r,
                        showDish: true,
                        onReply: () => _reply(context, r),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}