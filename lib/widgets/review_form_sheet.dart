import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/food.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'primary_button.dart';

/// Returns true if a review was saved.
Future<bool?> showReviewFormSheet(
  BuildContext context, {
  required Food food,
  Review? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReviewFormSheet(food: food, existing: existing),
  );
}

class _ReviewFormSheet extends StatefulWidget {
  final Food food;
  final Review? existing;
  const _ReviewFormSheet({required this.food, this.existing});

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  late double _rating = widget.existing?.rating ?? 0;
  late final _comment = TextEditingController(text: widget.existing?.comment);
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await ReviewService().submit(
        food: widget.food,
        rating: _rating,
        comment: _comment.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null ? 'Rate this dish' : 'Edit your review',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.food.name,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star : Icons.star_border,
                    size: 38,
                    color: const Color(0xFFF5A623),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _comment,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Tell others about the taste, portion, delivery…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            text: _saving ? 'Saving…' : 'Submit review',
            disabled: _rating == 0 || _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}