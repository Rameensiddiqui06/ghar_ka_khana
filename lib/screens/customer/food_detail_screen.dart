

// import 'package:flutter/material.dart';
// import '../../core/app_colors.dart';
// import '../../core/color_utils.dart';
// import '../../models/food.dart';
// import '../../models/seller.dart';
// import '../../services/cart_controller.dart';
// import '../../services/food_service.dart';
// import '../../widgets/primary_button.dart';
// import '../../widgets/qty_selector.dart';
// import '../../widgets/review_card.dart';
// import '../../widgets/safe_image.dart';
// import '../../widgets/star_row.dart';
// import '../../widgets/tab_strip.dart';

// class FoodDetailScreen extends StatefulWidget {
//   final String foodId;
//   final VoidCallback onBack;
//   final Set<String> favorites;
//   final void Function(String id) onFav;
//   final void Function(String screen, {Map<String, dynamic>? params}) onNav;
//   final CartController cart;

//   const FoodDetailScreen({
//     super.key,
//     required this.foodId,
//     required this.onBack,
//     required this.favorites,
//     required this.onFav,
//     required this.onNav,
//     required this.cart,
//   });

//   @override
//   State<FoodDetailScreen> createState() => _FoodDetailScreenState();
// }

// class _FoodDetailScreenState extends State<FoodDetailScreen> {
//   final _service = FoodService();
//   Food? _food;
//   Seller? _seller;
//   bool _loading = true;
//   int _qty = 1;
//   int _tab = 0;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     try {
//       final food = await _service.getFoodById(widget.foodId);
//       Seller? seller;
//       if (food != null) {
//         try {
//           seller = await _service.getSellerById(food.sellerId);
//         } catch (e) {
//           debugPrint('Could not load seller: $e');
//         }
//       }
//       if (!mounted) return;
//       setState(() {
//         _food = food;
//         _seller = seller;
//         _loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading food: $e');
//       if (!mounted) return;
//       setState(() => _loading = false);
//     }
//   }

//   int get _maxQty {
//     final f = _food;
//     if (f == null) return 1;
//     return f.available > 0 ? f.available : 1;
//   }

//   void _addToCart(Food food) {
//     widget.cart.add(food, _qty);
//     final messenger = ScaffoldMessenger.of(context);
//     widget.onBack();
//     messenger.showSnackBar(
//       SnackBar(
//         content: Text('${food.name} added to cart'),
//         action: SnackBarAction(
//           label: 'View Cart',
//           onPressed: () => widget.onNav('cart'),
//         ),
//       ),
//     );
//   }

//   Widget _circleButton(IconData icon, VoidCallback onTap, {Color? color}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 20, color: color ?? AppColors.text),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         backgroundColor: AppColors.cream,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final food = _food;
//     if (food == null) {
//       return Scaffold(
//         backgroundColor: AppColors.cream,
//         body: SafeArea(
//           child: Column(
//             children: [
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: _circleButton(Icons.arrow_back, widget.onBack),
//                 ),
//               ),
//               const Expanded(
//                 child: Center(
//                   child: Text(
//                     'Dish not found',
//                     style: TextStyle(color: AppColors.muted),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final isFav = widget.favorites.contains(food.id);

//     return Scaffold(
//       backgroundColor: AppColors.cream,
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 // Cover image with back + heart
//                 Stack(
//                   children: [
//                     SafeImage(
//                       imageUrl: food.imageUrl,
//                       emoji: food.emoji,
//                       bgColor: hexToColor(food.bgColorHex),
//                       width: double.infinity,
//                       height: 220,
//                     ),
//                     SafeArea(
//                       bottom: false,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _circleButton(Icons.arrow_back, widget.onBack),
//                             _circleButton(
//                               isFav ? Icons.favorite : Icons.favorite_border,
//                               () {
//                                 widget.onFav(food.id);
//                                 setState(() {});
//                               },
//                               color: isFav ? AppColors.error : AppColors.text,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               food.name,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.text,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'Rs. ${food.price}',
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.primary,
//                                 ),
//                               ),
//                               const Text(
//                                 'per portion',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: AppColors.muted,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           StarRow(rating: food.rating, size: 14),
//                           const SizedBox(width: 6),
//                           Text(
//                             '${food.rating} (${food.reviews} reviews)',
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: AppColors.text2,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),

//                       // Stats
//                       Row(
//                         children: [
//                           _stat(
//                             '⏱️',
//                             food.prepTime.isEmpty ? '—' : food.prepTime,
//                           ),
//                           const SizedBox(width: 10),
//                           _stat(
//                             '🍽️',
//                             food.portionSize.isEmpty ? '—' : food.portionSize,
//                           ),
//                           const SizedBox(width: 10),
//                           _stat('✅', '${food.available} available'),
//                         ],
//                       ),
//                       const SizedBox(height: 16),

//                       _sellerCard(food),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),
//                 TabStrip(
//                   labels: const ['About', 'Reviews'],
//                   index: _tab,
//                   onChanged: (i) => setState(() => _tab = i),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: _tabBody(food),
//                 ),
//               ],
//             ),
//           ),

//           // Bottom bar: quantity + add to cart
//           Container(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: AppColors.sand)),
//             ),
//             child: SafeArea(
//               top: false,
//               child: Row(
//                 children: [
//                   QtySelector(
//                     qty: _qty,
//                     onDec: () {
//                       if (_qty > 1) setState(() => _qty--);
//                     },
//                     onInc: () {
//                       if (_qty < _maxQty) setState(() => _qty++);
//                     },
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: PrimaryButton(
//                       text: food.available > 0
//                           ? 'Add to Cart · Rs. ${food.price * _qty}'
//                           : 'Sold out',
//                       disabled: food.available <= 0,
//                       onPressed: () => _addToCart(food),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _stat(String emoji, String label) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
//         decoration: BoxDecoration(
//           color: AppColors.primary.withOpacity(0.07),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Text(emoji, style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 6),
//             Text(
//               label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.text2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sellerCard(Food food) {
//     final seller = _seller;
//     final rating = seller?.rating;

//     return GestureDetector(
//       onTap: () => widget.onNav('seller', params: {'sellerId': food.sellerId}),
//       child: Container(
//         padding: const EdgeInsets.all(12),
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
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: SafeImage(
//                 imageUrl: seller?.avatarUrl,
//                 emoji: seller?.avatarEmoji ?? '👩‍🍳',
//                 bgColor: seller != null
//                     ? hexToColor(seller.avatarBgHex)
//                     : AppColors.sand,
//                 width: 48,
//                 height: 48,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Flexible(
//                         child: Text(
//                           food.sellerName,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.text,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (seller != null) ...[
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         StarRow(rating: rating!, size: 10),
//                         const SizedBox(width: 6),
//                         Text(
//                           '${seller.rating} · ${seller.reviews} reviews',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: AppColors.muted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _tabBody(Food food) {
//     switch (_tab) {
//       case 1:
//         return Column(
//           children: kDummyReviews.map((r) => ReviewCard(review: r)).toList(),
//         );
//       default:
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               food.description.isEmpty
//                   ? 'No description yet.'
//                   : food.description,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColors.text2,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.07),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'Delivery estimate',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.text,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     '30–45 minutes · Rs. ${CartController.deliveryFeePerSeller} delivery fee',
//                     style: TextStyle(fontSize: 13, color: AppColors.text2),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//     }
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/color_utils.dart';
import '../../models/food.dart';
import '../../models/review.dart';
import '../../models/seller.dart';
import '../../services/cart_controller.dart';
import '../../services/food_service.dart';
import '../../services/review_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/qty_selector.dart';
import '../../widgets/review_form_sheet.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/safe_image.dart';
import '../../widgets/star_row.dart';
import '../../widgets/tab_strip.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;
  final VoidCallback onBack;
  final Set<String> favorites;
  final void Function(String id) onFav;
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;
  final CartController cart;

  const FoodDetailScreen({
    super.key,
    required this.foodId,
    required this.onBack,
    required this.favorites,
    required this.onFav,
    required this.onNav,
    required this.cart,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _service = FoodService();
  Food? _food;
  Seller? _seller;
  bool _loading = true;
  int _qty = 1;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final food = await _service.getFoodById(widget.foodId);
      Seller? seller;
      if (food != null) {
        try {
          seller = await _service.getSellerById(food.sellerId);
        } catch (e) {
          debugPrint('Could not load seller: $e');
        }
      }
      if (!mounted) return;
      setState(() {
        _food = food;
        _seller = seller;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading food: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int get _maxQty {
    final f = _food;
    if (f == null) return 1;
    return f.available > 0 ? f.available : 1;
  }

  void _addToCart(Food food) {
    widget.cart.add(food, _qty);
    final messenger = ScaffoldMessenger.of(context);
    widget.onBack();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${food.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => widget.onNav('cart'),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final food = _food;
    if (food == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _circleButton(Icons.arrow_back, widget.onBack),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Dish not found',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isFav = widget.favorites.contains(food.id);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Cover image with back + heart
                Stack(
                  children: [
                    SafeImage(
                      imageUrl: food.imageUrl,
                      emoji: food.emoji,
                      bgColor: hexToColor(food.bgColorHex),
                      width: double.infinity,
                      height: 220,
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _circleButton(Icons.arrow_back, widget.onBack),
                            _circleButton(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              () {
                                widget.onFav(food.id);
                                setState(() {});
                              },
                              color: isFav ? AppColors.error : AppColors.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. ${food.price}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Text(
                                'per portion',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StarRow(rating: food.rating, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${food.rating} (${food.reviews} reviews)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.text2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        children: [
                          _stat(
                            '⏱️',
                            food.prepTime.isEmpty ? '—' : food.prepTime,
                          ),
                          const SizedBox(width: 10),
                          _stat(
                            '🍽️',
                            food.portionSize.isEmpty ? '—' : food.portionSize,
                          ),
                          const SizedBox(width: 10),
                          _stat('✅', '${food.available} available'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _sellerCard(food),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                TabStrip(
                  labels: const ['About', 'Reviews'],
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _tabBody(food),
                ),
              ],
            ),
          ),

          // Bottom bar: quantity + add to cart
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.sand)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  QtySelector(
                    qty: _qty,
                    onDec: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                    onInc: () {
                      if (_qty < _maxQty) setState(() => _qty++);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: food.available > 0
                          ? 'Add to Cart · Rs. ${food.price * _qty}'
                          : 'Sold out',
                      disabled: food.available <= 0,
                      onPressed: () => _addToCart(food),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellerCard(Food food) {
    final seller = _seller;
    final rating = seller?.rating;

    return GestureDetector(
      onTap: () => widget.onNav('seller', params: {'sellerId': food.sellerId}),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SafeImage(
                imageUrl: seller?.avatarUrl,
                emoji: seller?.avatarEmoji ?? '👩‍🍳',
                bgColor: seller != null
                    ? hexToColor(seller.avatarBgHex)
                    : AppColors.sand,
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          food.sellerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (seller != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StarRow(rating: rating!, size: 10),
                        const SizedBox(width: 6),
                        Text(
                          '${seller.rating} · ${seller.reviews} reviews',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  // ---------- Reviews ----------

  Future<void> _openReviewForm(Food food, Review? mine) async {
    final saved = await showReviewFormSheet(
      context,
      food: food,
      existing: mine,
    );
    if (saved == true) _load(); // refresh the average rating at the top
  }

  Widget _reviewsTab(Food food) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final canReview = uid != null && uid != food.sellerId;

    return StreamBuilder<List<Review>>(
      stream: ReviewService().streamForFood(food.id),
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
        Review? mine;
        for (final r in reviews) {
          if (r.customerId == uid) mine = r;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canReview)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openReviewForm(food, mine),
                  icon: const Icon(Icons.star_border),
                  label: Text(
                    mine == null ? 'Write a review' : 'Edit your review',
                  ),
                ),
              ),
            if (canReview) const SizedBox(height: 16),
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No reviews yet. Be the first!',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ...reviews.map((r) => ReviewTile(review: r)),
          ],
        );
      },
    );
  }

  Widget _tabBody(Food food) {
    switch (_tab) {
      case 1:
        return _reviewsTab(food);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.description.isEmpty
                  ? 'No description yet.'
                  : food.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text2,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Delivery estimate',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '30–45 minutes · Rs. ${CartController.deliveryFeePerSeller} delivery fee',
                    style: TextStyle(fontSize: 13, color: AppColors.text2),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}