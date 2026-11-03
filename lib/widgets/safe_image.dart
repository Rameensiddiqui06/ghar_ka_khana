
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeImage extends StatelessWidget {
  final String? imageUrl;
  final String emoji;
  final Color bgColor;
  final double? width;
  final double? height;

  const SafeImage({
    super.key,
    this.imageUrl,
    this.emoji = '🍽️',
    required this.bgColor,
    this.width,
    this.height,
  });

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  // Local bundled images are stored as "assests/..." (or "assets/...").
  bool get _isAsset =>
      imageUrl != null &&
      (imageUrl!.startsWith('assests/') || imageUrl!.startsWith('assets/'));

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;
    if (!hasUrl) return _fallback();

    // Local image bundled with the app.
    if (_isAsset) {
      return Image.asset(
        imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    // Remote image (e.g. a seller uploads a photo later).
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => _fallback(),
      errorWidget: (context, url, error) => _fallback(),
    );
  }
}
