import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/color_utils.dart';
import '../models/food.dart';
import 'safe_image.dart';
import 'star_row.dart';

class FoodCardV extends StatelessWidget {
  final Food food;
  final VoidCallback onPress;
  final bool isFav;
  final VoidCallback onFav;

  const FoodCardV({super.key, required this.food, required this.onPress, required this.isFav, required this.onFav});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SafeImage(imageUrl: food.imageUrl, emoji: food.emoji, bgColor: hexToColor(food.bgColorHex), width: 172, height: 120),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFav,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 15, color: isFav ? AppColors.error : AppColors.muted),
                    ),
                  ),
                ),
                if (food.available <= 5)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                      child: Text('${food.available} left', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(food.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rs. ${food.price}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Row(children: [StarRow(rating: food.rating, size: 10), const SizedBox(width: 4), Text('${food.rating}', style: const TextStyle(fontSize: 10, color: AppColors.muted))]),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('⏱ ${food.prepTime}', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

