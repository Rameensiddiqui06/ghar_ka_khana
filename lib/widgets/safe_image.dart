
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class SafeImage extends StatelessWidget {
//   final String? imageUrl;
//   final String emoji;
//   final Color bgColor;
//   final double? width;
//   final double? height;

//   const SafeImage({
//     super.key,
//     this.imageUrl,
//     this.emoji = '🍽️',
//     required this.bgColor,
//     this.width,
//     this.height,
//   });

//   Widget _fallback() {
//     return Container(
//       width: width,
//       height: height,
//       color: bgColor,
//       alignment: Alignment.center,
//       child: Text(emoji, style: const TextStyle(fontSize: 32)),
//     );
//   }

//   // Local bundled images are stored as "assests/..." (or "assets/...").
//   bool get _isAsset =>
//       imageUrl != null &&
//       (imageUrl!.startsWith('assests/') || imageUrl!.startsWith('assets/'));

//   @override
//   Widget build(BuildContext context) {
//     final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;
//     if (!hasUrl) return _fallback();

//     // Local image bundled with the app.
//     if (_isAsset) {
//       return Image.asset(
//         imageUrl!,
//         width: width,
//         height: height,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => _fallback(),
//       );
//     }

//     // Remote image (e.g. a seller uploads a photo later).
//     return CachedNetworkImage(
//       imageUrl: imageUrl!,
//       width: width,
//       height: height,
//       fit: BoxFit.cover,
//       fadeInDuration: const Duration(milliseconds: 200),
//       placeholder: (context, url) => _fallback(),
//       errorWidget: (context, url, error) => _fallback(),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeImage extends StatelessWidget {
  final String? imageUrl;
  final String emoji;
  final Color bgColor;
  final double? width;
  final double? height;

  /// How the photo fills the box. `cover` fills it completely (and crops the
  /// edges of photos with a different shape). `contain` shows the whole photo
  /// but may leave empty bars.
  final BoxFit fit;

  /// Which part of the photo stays visible when it is cropped.
  final Alignment alignment;

  const SafeImage({
    super.key,
    this.imageUrl,
    this.emoji = '🍽️',
    required this.bgColor,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  Widget _fallback({bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  // Local bundled images are stored as "assests/..." (or "assets/...").
  bool get _isAsset =>
      imageUrl != null &&
      (imageUrl!.trim().startsWith('assests/') ||
          imageUrl!.trim().startsWith('assets/'));

  /// Cleans the URL and, for Unsplash links, asks the server for a sensible
  /// size (800px wide) instead of the multi-megabyte original. Huge originals
  /// are the main reason photos load slowly or appear half drawn.
  String _optimized(String raw) {
    final url = raw.trim();
    final u = Uri.tryParse(url);
    if (u == null) return url;
    if (u.host == 'images.unsplash.com' && !u.queryParameters.containsKey('w')) {
      return u.replace(queryParameters: {
        ...u.queryParameters,
        'auto': 'format',
        'fit': 'crop',
        'w': '800',
        'q': '70',
      }).toString();
    }
    return url;
  }

  int? get _cacheWidth {
    final w = width;
    if (w == null || !w.isFinite || w <= 0) return 1000;
    return (w * 2).round().clamp(150, 1000);
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim() ?? '';
    if (raw.isEmpty) return _fallback();

    // Local image bundled with the app.
    if (_isAsset) {
      return Image.asset(
        raw,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    final url = _optimized(raw);

    // Remote image (e.g. a seller uploads a photo later).
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      memCacheWidth: _cacheWidth,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, _) => _fallback(loading: true),
      errorWidget: (context, _, error) {
        debugPrint('SafeImage failed: $url -> $error');
        return _fallback();
      },
    );
  }
}