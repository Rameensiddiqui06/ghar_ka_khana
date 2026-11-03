

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/color_utils.dart';
import '../../models/seller.dart';
import '../../models/category.dart';
import '../../services/food_service.dart';
import '../../widgets/safe_image.dart';
import '../../widgets/section_header.dart';
import '../../widgets/star_row.dart';
import '../../core/unsplash.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;
  final Set<String> favorites;
  final void Function(String id) onFav;

  const HomeScreen({
    super.key,
    required this.onNav,
    required this.favorites,
    required this.onFav,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _foodService = FoodService();

  List<Seller> _sellers = [];
  List<FoodCategory> _categories = [];

  bool _loading = true;
  String? _error;
  String _activeCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sellers = await _foodService.getSellers();
      final categories = await _foodService.getCategories();

      if (!mounted) return;

      setState(() {
        _sellers = sellers;
        _categories = categories;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Error loading home screen data: $e');

      if (!mounted) return;

      setState(() {
        _error = 'Could not load home data. Pull down to retry.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Search bar
          Container(
            color: AppColors.cream,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: GestureDetector(
              onTap: () => widget.onNav('explore'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sand, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 18, color: AppColors.muted),
                    SizedBox(width: 10),
                    Text(
                      'What are you craving today?',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Homemade food banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  SafeImage(
                    imageUrl: unsplashUrl(
                      '1504674900247-0877df9cc836',
                      w: 800,
                      h: 450,
                    ),
                    emoji: '🍽️',
                    bgColor: const Color(0xFFC9873A),
                    width: double.infinity,
                    height: 180,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xCC2C2420), Colors.transparent],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Homemade goodness,\njust a tap away.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => widget.onNav('explore'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Explore Food',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Khana Buddy entry
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => widget.onNav('khanaBuddy'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
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
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🍲', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Khana Buddy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Not sure what to eat? Pick a craving and budget.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.text2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories
          const SectionHeader(title: 'Categories'),
          const SizedBox(height: 12),

          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip(
                  id: 'all',
                  name: 'All',
                  icon: '🍽️',
                  imageUrl: null,
                  bgColor: AppColors.sand,
                ),
                ..._categories.map(
                  (category) => _categoryChip(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    imageUrl: category.imageUrl,
                    bgColor: hexToColor(category.bgColorHex),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Top Home Cooks
          const SectionHeader(title: 'Top Home Cooks'),
          const SizedBox(height: 12),

          ..._sellers
              .take(3)
              .map(
                (seller) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: GestureDetector(
                    onTap: () =>
                        widget.onNav('seller', params: {'sellerId': seller.id}),
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
                              imageUrl: seller.avatarUrl,
                              emoji: seller.avatarEmoji,
                              bgColor: hexToColor(seller.avatarBgHex),
                              width: 56,
                              height: 56,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  seller.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    StarRow(rating: seller.rating, size: 10),
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

                                const SizedBox(height: 4),

                                Text(
                                  '📍 ${seller.location} · ${seller.distance}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: seller.cuisines
                                      .map(
                                        (cuisine) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.cream,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            cuisine,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.text2,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _categoryChip({
    required String id,
    required String name,
    required String icon,
    String? imageUrl,
    required Color bgColor,
  }) {
    final active = _activeCategory == id;

    return GestureDetector(
      onTap: () {
        setState(() => _activeCategory = id);
        widget.onNav('explore', params: {'category': id});
      },
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: id == 'all'
                  ? Container(
                      width: 40,
                      height: 40,
                      color: AppColors.sand,
                      alignment: Alignment.center,
                      child: const Text('🍽️', style: TextStyle(fontSize: 18)),
                    )
                  : SafeImage(
                      imageUrl: imageUrl,
                      emoji: icon,
                      bgColor: bgColor,
                      width: 40,
                      height: 40,
                    ),
            ),

            const SizedBox(height: 6),

            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
