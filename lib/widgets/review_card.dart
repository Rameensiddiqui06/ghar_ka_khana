import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'star_row.dart';

/// Dummy review data until real reviews exist.
class DummyReview {
  final String name;
  final double rating;
  final String text;
  final String when;
  const DummyReview(this.name, this.rating, this.text, this.when);
}

const kDummyReviews = [
  DummyReview(
    'Ayesha K.',
    5,
    'Tastes exactly like home. Fresh and still hot when it arrived.',
    '2 days ago',
  ),
  DummyReview(
    'Hamza R.',
    4.5,
    'Great portions and very friendly. Will definitely order again.',
    '1 week ago',
  ),
  DummyReview(
    'Sana M.',
    5,
    'Best I have had in Karachi. Highly recommend!',
    '2 weeks ago',
  ),
];

class ReviewCard extends StatelessWidget {
  final DummyReview review;
  const ReviewCard({super.key, required this.review});

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
                  review.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                review.when,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          StarRow(rating: review.rating, size: 11),
          const SizedBox(height: 8),
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.text2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
