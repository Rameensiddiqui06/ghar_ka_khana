import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/color_utils.dart';
import '../models/food.dart';
import 'safe_image.dart';
import 'star_row.dart';

class FoodCardH extends StatelessWidget {
  final Food food;
  final VoidCallback onPress;
  final bool isFav;
  final VoidCallback onFav;

  const FoodCardH({super.key, required this.food, required this.onPress, required this.isFav, required this.onFav});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SafeImage(imageUrl: food.imageUrl, emoji: food.emoji, bgColor: hexToColor(food.bgColorHex), width: 76, height: 76),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                  Text(food.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Row(children: [StarRow(rating: food.rating, size: 10), const SizedBox(width: 6), Text('(${food.reviews})', style: const TextStyle(fontSize: 11, color: AppColors.muted))]),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rs. ${food.price}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      GestureDetector(onTap: onFav, child: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 18, color: isFav ? AppColors.error : AppColors.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}