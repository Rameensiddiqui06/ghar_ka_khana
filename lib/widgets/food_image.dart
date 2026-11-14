import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

const kDefaultFoodAsset = 'assests/default_food.jpg';

// The old default photo that was saved into dishes with no picture.
const _legacyDefaultPhotoId = 'photo-1546069901-ba9599a7e63c';

class FoodImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FoodImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  Widget _default() {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(kDefaultFoodAsset, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? '').trim();

    // No photo, or the old stock default: show the new default image.
    if (url.isEmpty || url.contains(_legacyDefaultPhotoId)) {
      return _default();
    }

    // Photo taken/picked by the seller, stored as a data URI.
    if (url.startsWith('data:image')) {
      try {
        final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _default(),
        );
      } catch (_) {
        return _default();
      }
    }

    // Older foods that still have a normal web URL.
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) =>
          Container(width: width, height: height, color: AppColors.sand),
      errorWidget: (_, __, ___) => _default(),
    );
  }
}