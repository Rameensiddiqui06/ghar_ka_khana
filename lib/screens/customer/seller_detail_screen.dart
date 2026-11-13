

// import 'package:flutter/material.dart';
// import '../../core/app_colors.dart';
// import '../../core/color_utils.dart';
// import '../../models/food.dart';
// import '../../models/seller.dart';
// import '../../services/food_service.dart';
// import '../../widgets/food_card_h.dart';
// import '../../widgets/review_card.dart';
// import '../../widgets/safe_image.dart';
// import '../../widgets/star_row.dart';
// import '../../widgets/tab_strip.dart';

// class SellerDetailScreen extends StatefulWidget {
//   final String sellerId;
//   final VoidCallback onBack;
//   final Set<String> favorites;
//   final void Function(String id) onFav;
//   final void Function(String screen, {Map<String, dynamic>? params}) onNav;

//   const SellerDetailScreen({
//     super.key,
//     required this.sellerId,
//     required this.onBack,
//     required this.favorites,
//     required this.onFav,
//     required this.onNav,
//   });

//   @override
//   State<SellerDetailScreen> createState() => _SellerDetailScreenState();
// }

// class _SellerDetailScreenState extends State<SellerDetailScreen> {
//   final _service = FoodService();
//   Seller? _seller;
//   List<Food> _foods = [];
//   bool _loading = true;
//   int _tab = 0;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     try {
//       final seller = await _service.getSellerById(widget.sellerId);
//       final foods = seller == null
//           ? <Food>[]
//           : await _service.getFoodsBySeller(widget.sellerId);
//       if (!mounted) return;
//       setState(() {
//         _seller = seller;
//         _foods = foods;
//         _loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading seller: $e');
//       if (!mounted) return;
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         backgroundColor: AppColors.cream,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final seller = _seller;
//     if (seller == null) {
//       return Scaffold(
//         backgroundColor: AppColors.cream,
//         body: SafeArea(
//           child: Column(
//             children: [
//               Align(alignment: Alignment.centerLeft, child: _backButton()),
//               const Expanded(
//                 child: Center(
//                   child: Text(
//                     'Seller not found',
//                     style: TextStyle(color: AppColors.muted),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.cream,
//       body: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           _header(seller),
//           _info(seller),
//           TabStrip(
//             labels: const ['Menu', 'Reviews', 'About'],
//             index: _tab,
//             onChanged: (i) => setState(() => _tab = i),
//           ),
//           if (_tab == 0) _menuTab(),
//           if (_tab == 1) _reviewsTab(),
//           if (_tab == 2) _aboutTab(seller),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _backButton() {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: GestureDetector(
//         onTap: widget.onBack,
//         child: Container(
//           width: 40,
//           height: 40,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.arrow_back, size: 20, color: AppColors.text),
//         ),
//       ),
//     );
//   }

//   // Cover photo + back button + avatar overlapping the bottom edge
//   Widget _header(Seller seller) {
//     return SizedBox(
//       height: 240,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           SafeImage(
//             imageUrl: seller.coverUrl.isEmpty ? null : seller.coverUrl,
//             emoji: seller.coverEmoji,
//             bgColor: hexToColor(seller.coverBgHex),
//             width: double.infinity,
//             height: 190,
//           ),
//           SafeArea(
//             bottom: false,
//             child: Align(alignment: Alignment.topLeft, child: _backButton()),
//           ),
//           Positioned(
//             left: 16,
//             bottom: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: AppColors.cream, width: 3),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: SafeImage(
//                   imageUrl: seller.avatarUrl,
//                   emoji: seller.avatarEmoji,
//                   bgColor: hexToColor(seller.avatarBgHex),
//                   width: 76,
//                   height: 76,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _info(Seller seller) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Flexible(
//                 child: Text(
//                   seller.name,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.text,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               StarRow(rating: seller.rating, size: 13),
//               const SizedBox(width: 6),
//               Text(
//                 '${seller.rating} · ${seller.reviews} reviews',
//                 style: const TextStyle(fontSize: 12, color: AppColors.muted),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (seller.description.isNotEmpty) ...[
//             Text(
//               seller.description,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: AppColors.text2,
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//           Text(
//             '📍 ${seller.location} · ${seller.distance}',
//             style: const TextStyle(fontSize: 12, color: AppColors.muted),
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8,
//             runSpacing: 6,
//             children: [
//               ...seller.cuisines.map(
//                 (c) => _chip(c, AppColors.sand, AppColors.text2),
//               ),
//               _chip(
//                 '🌿 Fresh Daily',
//                 const Color(0xFFEDF7F1),
//                 AppColors.success,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _chip(String label, Color bg, Color fg) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(999),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
//       ),
//     );
//   }

//   // ---------- Menu tab (real foods from Firestore) ----------
//   Widget _menuTab() {
//     if (_foods.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(32),
//         child: Center(
//           child: Text(
//             'No dishes on the menu yet.',
//             style: TextStyle(fontSize: 13, color: AppColors.muted),
//           ),
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: _foods
//             .map(
//               (f) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: FoodCardH(
//                   food: f,
//                   isFav: widget.favorites.contains(f.id),
//                   onFav: () {
//                     widget.onFav(f.id);
//                     // The pushed route isn't rebuilt by the parent, so refresh here.
//                     setState(() {});
//                   },
//                   onPress: () =>
//                       widget.onNav('product', params: {'foodId': f.id}),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   // ---------- Reviews tab (dummy) ----------
//   Widget _reviewsTab() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: kDummyReviews.map((r) => ReviewCard(review: r)).toList(),
//       ),
//     );
//   }

//   // ---------- About tab ----------
//   Widget _aboutTab(Seller seller) {
//     Widget row(String label, String value) => Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 12, color: AppColors.muted),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.text,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.07),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             row('Kitchen', seller.name),
//             row('Location', seller.location),
//             row('Distance', seller.distance),
//             row('Cuisines', seller.cuisines.join(', ')),
//             if (seller.hours.isNotEmpty) row('Hours', seller.hours),
//             if (seller.days.isNotEmpty) row('Days', seller.days),
//             if (seller.story.isNotEmpty) ...[
//               const Divider(height: 24, color: AppColors.sand),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   seller.story,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: AppColors.text2,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/color_utils.dart';
import '../../models/food.dart';
import '../../models/review.dart';
import '../../models/seller.dart';
import '../../services/food_service.dart';
import '../../services/review_service.dart';
import '../../widgets/food_card_h.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/safe_image.dart';
import '../../widgets/star_row.dart';
import '../../widgets/tab_strip.dart';

class SellerDetailScreen extends StatefulWidget {
  final String sellerId;
  final VoidCallback onBack;
  final Set<String> favorites;
  final void Function(String id) onFav;
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;

  const SellerDetailScreen({
    super.key,
    required this.sellerId,
    required this.onBack,
    required this.favorites,
    required this.onFav,
    required this.onNav,
  });

  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  final _service = FoodService();
  Seller? _seller;
  List<Food> _foods = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final seller = await _service.getSellerById(widget.sellerId);
      final foods = seller == null
          ? <Food>[]
          : await _service.getFoodsBySeller(widget.sellerId);
      if (!mounted) return;
      setState(() {
        _seller = seller;
        _foods = foods;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading seller: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final seller = _seller;
    if (seller == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: _backButton()),
              const Expanded(
                child: Center(
                  child: Text(
                    'Seller not found',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(seller),
          _info(seller),
          TabStrip(
            labels: const ['Menu', 'Reviews', 'About'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          if (_tab == 0) _menuTab(),
          if (_tab == 1) _reviewsTab(),
          if (_tab == 2) _aboutTab(seller),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: widget.onBack,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 20, color: AppColors.text),
        ),
      ),
    );
  }

  // Cover photo + back button + avatar overlapping the bottom edge
  Widget _header(Seller seller) {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeImage(
            imageUrl: seller.coverUrl.isEmpty ? null : seller.coverUrl,
            emoji: seller.coverEmoji,
            bgColor: hexToColor(seller.coverBgHex),
            width: double.infinity,
            height: 190,
          ),
          SafeArea(
            bottom: false,
            child: Align(alignment: Alignment.topLeft, child: _backButton()),
          ),
          Positioned(
            left: 16,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cream, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SafeImage(
                  imageUrl: seller.avatarUrl,
                  emoji: seller.avatarEmoji,
                  bgColor: hexToColor(seller.avatarBgHex),
                  width: 76,
                  height: 76,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(Seller seller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  seller.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              StarRow(rating: seller.rating, size: 13),
              const SizedBox(width: 6),
              Text(
                '${seller.rating} · ${seller.reviews} reviews',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (seller.description.isNotEmpty) ...[
            Text(
              seller.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            '📍 ${seller.location} · ${seller.distance}',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ...seller.cuisines.map(
                (c) => _chip(c, AppColors.sand, AppColors.text2),
              ),
              _chip(
                '🌿 Fresh Daily',
                const Color(0xFFEDF7F1),
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }

  // ---------- Menu tab (real foods from Firestore) ----------
  Widget _menuTab() {
    if (_foods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No dishes on the menu yet.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _foods
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FoodCardH(
                  food: f,
                  isFav: widget.favorites.contains(f.id),
                  onFav: () {
                    widget.onFav(f.id);
                    // The pushed route isn't rebuilt by the parent, so refresh here.
                    setState(() {});
                  },
                  onPress: () =>
                      widget.onNav('product', params: {'foodId': f.id}),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------- Reviews tab (real) ----------
  Widget _reviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<List<Review>>(
        stream: ReviewService().streamForSeller(widget.sellerId),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Text(
              'Could not load reviews.',
              style: TextStyle(color: AppColors.muted),
            );
          }
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final reviews = snap.data!;
          if (reviews.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No reviews yet.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            );
          }
          return Column(
            children: reviews
                .map((r) => ReviewTile(review: r, showDish: true))
                .toList(),
          );
        },
      ),
    );
  }

  // ---------- About tab ----------
  Widget _aboutTab(Seller seller) {
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
          children: [
            row('Kitchen', seller.name),
            row('Location', seller.location),
            row('Distance', seller.distance),
            row('Cuisines', seller.cuisines.join(', ')),
            if (seller.hours.isNotEmpty) row('Hours', seller.hours),
            if (seller.days.isNotEmpty) row('Days', seller.days),
            if (seller.story.isNotEmpty) ...[
              const Divider(height: 24, color: AppColors.sand),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  seller.story,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text2,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}