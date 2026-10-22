// import 'package:flutter/material.dart';

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

//   @override
//   Widget build(BuildContext context) {
//     final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

//     if (!hasUrl) {
//       return Container(
//         width: width,
//         height: height,
//         color: bgColor,
//         alignment: Alignment.center,
//         child: Text(emoji, style: const TextStyle(fontSize: 32)),
//       );
//     }

//     return Image.network(
//       imageUrl!,
//       width: width,
//       height: height,
//       fit: BoxFit.cover,
//       loadingBuilder: (context, child, progress) {
//         if (progress == null) return child;
//         return Container(
//           width: width,
//           height: height,
//           color: bgColor,
//           alignment: Alignment.center,
//           child: Text(emoji, style: const TextStyle(fontSize: 32)),
//         );
//       },
//       errorBuilder: (context, error, stack) {
//         return Container(
//           width: width,
//           height: height,
//           color: bgColor,
//           alignment: Alignment.center,
//           child: Text(emoji, style: const TextStyle(fontSize: 32)),
//         );
//       },
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

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;
    if (!hasUrl) return _fallback();

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