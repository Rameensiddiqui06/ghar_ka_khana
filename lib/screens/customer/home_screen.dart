import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/color_utils.dart';
import '../../models/food.dart';
import '../../models/seller.dart';
import '../../models/category.dart';
import '../../services/food_service.dart';
import '../../widgets/safe_image.dart';
import '../../widgets/section_header.dart';
import '../../widgets/food_card_v.dart';
import '../../widgets/food_card_h.dart';
import '../../widgets/star_row.dart';
import '../../core/unsplash.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;
  final Set<String> favorites;
  final void Function(String id) onFav;

  const HomeScreen({super.key, required this.onNav, required this.favorites, required this.onFav});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _foodService = FoodService();

  List<Food> _foods = [];
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
      final results = await Future.wait([
        _foodService.getFoods(),
        _foodService.getSellers(),
        _foodService.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _foods = results[0] as List<Food>;
        _sellers = results[1] as List<Seller>;
        _categories = results[2] as List<FoodCategory>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load food data. Pull down to retry.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(children: [const SizedBox(height: 120), Center(child: Text(_error!, style: const TextStyle(color: AppColors.muted)))]),
      );
    }

    final featured = _foods.where((f) => f.featured).toList();
    final fresh = _foods.where((f) => f.freshToday).toList();
    final limited = _foods.where((f) => f.available <= 10).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: AppColors.cream,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(children: [
                            Text('📍 ', style: TextStyle(fontSize: 12)),
                            Text('Deliver to ', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500)),
                            Text('DHA Phase 6 ▾', style: TextStyle(fontSize: 12, color: AppColors.text, fontWeight: FontWeight.w600)),
                          ]),
                          SizedBox(height: 2),
                          Text('Good afternoon 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNav('notifications'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Stack(children: [
                          Center(child: Text('🔔')),
                          Positioned(top: 4, right: 6, child: CircleAvatar(radius: 8, backgroundColor: AppColors.primary, child: Text('2', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)))),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => widget.onNav('explore'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.sand, width: 1.5)),
                    child: Row(children: const [Icon(Icons.search, size: 18, color: AppColors.muted), SizedBox(width: 10), Text('What are you craving today?', style: TextStyle(fontSize: 13, color: AppColors.muted))]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(children: [
                                SafeImage(imageUrl: unsplashUrl('1504674900247-0877df9cc836', w: 800, h: 450), emoji: '🍽️', bgColor: const Color(0xFFC9873A), width: double.infinity, height: 180),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC2C2420), Colors.transparent])),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Homemade goodness,\njust a tap away.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => widget.onNav('explore'),
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)), child: const Text('Explore Food', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Categories'),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip(id: 'all', name: 'All', icon: '🍽️', imageUrl: null, bgColor: AppColors.sand),
                ..._categories.map((c) => _categoryChip(id: c.id, name: c.name, icon: c.icon, imageUrl: c.imageUrl, bgColor: hexToColor(c.bgColorHex))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Popular Near You', onSeeAll: () => widget.onNav('explore')),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: featured.map((f) => Padding(padding: const EdgeInsets.only(right: 12), child: FoodCardV(food: f, onPress: () => widget.onNav('product', params: {'foodId': f.id}), isFav: widget.favorites.contains(f.id), onFav: () => widget.onFav(f.id)))).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Top Home Cooks'),
          const SizedBox(height: 12),
          ..._sellers.take(3).map((s) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: GestureDetector(
                  onTap: () => widget.onNav('seller', params: {'sellerId': s.id}),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 2))]),
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: SafeImage(imageUrl: s.avatarUrl, emoji: s.avatarEmoji, bgColor: hexToColor(s.avatarBgHex), width: 56, height: 56)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Flexible(child: Text(s.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text))),
                                if (s.verified) ...[
                                  const SizedBox(width: 6),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFEDF7F1), borderRadius: BorderRadius.circular(999)), child: const Text('✓ Verified', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success))),
                                ],
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [StarRow(rating: s.rating, size: 10), const SizedBox(width: 6), Text('${s.rating} · ${s.reviews} reviews', style: const TextStyle(fontSize: 11, color: AppColors.muted))]),
                              const SizedBox(height: 4),
                              Text('📍 ${s.location} · ${s.distance}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              const SizedBox(height: 6),
                              Wrap(spacing: 6, runSpacing: 4, children: s.cuisines.map((c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(999)), child: Text(c, style: const TextStyle(fontSize: 10, color: AppColors.text2, fontWeight: FontWeight.w500)))).toList()),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          const SectionHeader(title: '🌿 Fresh Today'),
          const SizedBox(height: 12),
          ...fresh.take(3).map((f) => Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: FoodCardH(food: f, onPress: () => widget.onNav('product', params: {'foodId': f.id}), isFav: widget.favorites.contains(f.id), onFav: () => widget.onFav(f.id)))),
          const SizedBox(height: 8),
          const SectionHeader(title: '⏳ Limited Availability'),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: limited.map((f) => Padding(padding: const EdgeInsets.only(right: 12), child: FoodCardV(food: f, onPress: () => widget.onNav('product', params: {'foodId': f.id}), isFav: widget.favorites.contains(f.id), onFav: () => widget.onFav(f.id)))).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

    Widget _categoryChip({required String id, required String name, required String icon, String? imageUrl, required Color bgColor}) {
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
        decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: id == 'all'
                  ? Container(width: 40, height: 40, color: AppColors.sand, alignment: Alignment.center, child: const Text('🍽️', style: TextStyle(fontSize: 18)))
                  : SafeImage(imageUrl: imageUrl, emoji: icon, bgColor: bgColor, width: 40, height: 40),
            ),
            const SizedBox(height: 6),
            Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text2)),
          ],
        ),
      ),
    );
  }
}