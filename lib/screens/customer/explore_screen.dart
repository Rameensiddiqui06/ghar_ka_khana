// import 'package:flutter/material.dart';
// import '../../core/app_colors.dart';
// import '../../core/color_utils.dart';
// import '../../models/food.dart';
// import '../../models/category.dart';
// import '../../services/food_service.dart';
// import '../../widgets/safe_image.dart';
// import '../../widgets/empty_state.dart';

// class ExploreScreen extends StatefulWidget {
//   final void Function(String screen, {Map<String, dynamic>? params}) onNav;
//   final Set<String> favorites;
//   final void Function(String id) onFav;

//   const ExploreScreen({super.key, required this.onNav, required this.favorites, required this.onFav});

//   @override
//   State<ExploreScreen> createState() => _ExploreScreenState();
// }

// class _ExploreScreenState extends State<ExploreScreen> {
//   final _foodService = FoodService();
//   final _searchController = TextEditingController();

//   List<Food> _foods = [];
//   List<FoodCategory> _categories = [];
//   bool _loading = true;
//   String? _error;

//   String _query = '';
//   String _category = 'all';
//   String _sort = 'recommended';

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     try {
//       final results = await Future.wait([_foodService.getFoods(), _foodService.getCategories()]);
//       if (!mounted) return;
//       setState(() {
//         _foods = results[0] as List<Food>;
//         _categories = results[1] as List<FoodCategory>;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = 'Could not load food data.';
//         _loading = false;
//       });
//     }
//   }

//   List<Food> get _filtered {
//     var list = _foods.where((f) {
//       final q = _query.isEmpty || f.name.toLowerCase().contains(_query.toLowerCase()) || f.sellerName.toLowerCase().contains(_query.toLowerCase());
//       final c = _category == 'all' || f.category == _category;
//       return q && c;
//     }).toList();

//     switch (_sort) {
//       case 'price-asc':
//         list.sort((a, b) => a.price.compareTo(b.price));
//         break;
//       case 'price-desc':
//         list.sort((a, b) => b.price.compareTo(a.price));
//         break;
//       case 'rating':
//         list.sort((a, b) => b.rating.compareTo(a.rating));
//         break;
//     }
//     return list;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) return const Center(child: CircularProgressIndicator());
//     if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: AppColors.muted)));

//     final filtered = _filtered;

//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           color: AppColors.cream,
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Explore Food', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                       decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.sand), borderRadius: BorderRadius.circular(12)),
//                       child: Row(children: [
//                         const Icon(Icons.search, size: 18, color: AppColors.muted),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             onChanged: (v) => setState(() => _query = v),
//                             decoration: const InputDecoration(hintText: 'Search food or cook…', hintStyle: TextStyle(fontSize: 13, color: AppColors.muted), border: InputBorder.none, isDense: true),
//                             style: const TextStyle(fontSize: 13, color: AppColors.text),
//                           ),
//                         ),
//                         if (_query.isNotEmpty) GestureDetector(onTap: () { _searchController.clear(); setState(() => _query = ''); }, child: const Icon(Icons.close, size: 16, color: AppColors.muted)),
//                       ]),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.sand), borderRadius: BorderRadius.circular(12)),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: _sort,
//                         onChanged: (v) => setState(() => _sort = v ?? 'recommended'),
//                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2),
//                         items: const [
//                           DropdownMenuItem(value: 'recommended', child: Text('Best')),
//                           DropdownMenuItem(value: 'rating', child: Text('Rating')),
//                           DropdownMenuItem(value: 'price-asc', child: Text('Low')),
//                           DropdownMenuItem(value: 'price-desc', child: Text('High')),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 52,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             children: [_chip(id: 'all', name: 'All', icon: '🍽️'), ..._categories.map((c) => _chip(id: c.id, name: c.name, icon: c.icon))],
//           ),
//         ),
//         Expanded(
//           child: filtered.isEmpty
//               ? const EmptyState(emoji: '🔍', title: 'No results found', subtitle: 'Try a different search or category')
//               : GridView.builder(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72),
//                   itemCount: filtered.length,
//                   itemBuilder: (context, i) {
//                     final f = filtered[i];
//                     final isFav = widget.favorites.contains(f.id);
//                     return GestureDetector(
//                       onTap: () => widget.onNav('product', params: {'foodId': f.id}),
//                       child: Container(
//                         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 2))]),
//                         clipBehavior: Clip.antiAlias,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AspectRatio(
//                               aspectRatio: 1.5,
//                               child: Stack(children: [
//                                 SafeImage(imageUrl: f.imageUrl, emoji: f.emoji, bgColor: hexToColor(f.bgColorHex)),
//                                 Positioned(
//                                   top: 8,
//                                   right: 8,
//                                   child: GestureDetector(
//                                     onTap: () => widget.onFav(f.id),
//                                     child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle), alignment: Alignment.center, child: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 13, color: isFav ? AppColors.error : AppColors.muted)),
//                                   ),
//                                 ),
//                               ]),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(10),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
//                                   const SizedBox(height: 2),
//                                   Text(f.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
//                                   const SizedBox(height: 6),
//                                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Rs. ${f.price}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)), Text('★ ${f.rating}', style: const TextStyle(fontSize: 10, color: AppColors.muted))]),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _chip({required String id, required String name, required String icon}) {
//     final active = _category == id;
//     return GestureDetector(
//       onTap: () => setState(() => _category = id),
//       child: Container(
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(999), border: active ? null : Border.all(color: AppColors.sand)),
//         child: Text('$icon  $name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text2)),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/color_utils.dart';
import '../../models/food.dart';
import '../../models/category.dart';
import '../../services/food_service.dart';
import '../../widgets/safe_image.dart';
import '../../widgets/empty_state.dart';

class ExploreScreen extends StatefulWidget {
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;
  final Set<String> favorites;
  final void Function(String id) onFav;
  final String? initialCategory;

  const ExploreScreen({super.key, required this.onNav, required this.favorites, required this.onFav, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _foodService = FoodService();
  final _searchController = TextEditingController();

  List<Food> _foods = [];
  List<FoodCategory> _categories = [];
  bool _loading = true;
  String? _error;

  String _query = '';
  String _category = 'all';
  String _sort = 'recommended';

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'all';
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([_foodService.getFoods(), _foodService.getCategories()]);
      if (!mounted) return;
      setState(() {
        _foods = results[0] as List<Food>;
        _categories = results[1] as List<FoodCategory>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load food data.';
        _loading = false;
      });
    }
  }

  List<Food> get _filtered {
    var list = _foods.where((f) {
      final q = _query.isEmpty || f.name.toLowerCase().contains(_query.toLowerCase()) || f.sellerName.toLowerCase().contains(_query.toLowerCase());
      final c = _category == 'all' || f.category == _category;
      return q && c;
    }).toList();

    switch (_sort) {
      case 'price-asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: AppColors.muted)));

    final filtered = _filtered;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.cream,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Explore Food', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.sand), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.search, size: 18, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(hintText: 'Search food or cook…', hintStyle: TextStyle(fontSize: 13, color: AppColors.muted), border: InputBorder.none, isDense: true),
                            style: const TextStyle(fontSize: 13, color: AppColors.text),
                          ),
                        ),
                        if (_query.isNotEmpty) GestureDetector(onTap: () { _searchController.clear(); setState(() => _query = ''); }, child: const Icon(Icons.close, size: 16, color: AppColors.muted)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.sand), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sort,
                        onChanged: (v) => setState(() => _sort = v ?? 'recommended'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2),
                        items: const [
                          DropdownMenuItem(value: 'recommended', child: Text('Best')),
                          DropdownMenuItem(value: 'rating', child: Text('Rating')),
                          DropdownMenuItem(value: 'price-asc', child: Text('Low')),
                          DropdownMenuItem(value: 'price-desc', child: Text('High')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [_chip(id: 'all', name: 'All', icon: '🍽️'), ..._categories.map((c) => _chip(id: c.id, name: c.name, icon: c.icon))],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(emoji: '🔍', title: 'No results found', subtitle: 'Try a different search or category')
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final f = filtered[i];
                    final isFav = widget.favorites.contains(f.id);
                    return GestureDetector(
                      onTap: () => widget.onNav('product', params: {'foodId': f.id}),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 2))]),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: Stack(children: [
                                SafeImage(imageUrl: f.imageUrl, emoji: f.emoji, bgColor: hexToColor(f.bgColorHex)),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => widget.onFav(f.id),
                                    child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle), alignment: Alignment.center, child: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 13, color: isFav ? AppColors.error : AppColors.muted)),
                                  ),
                                ),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(f.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                                  const SizedBox(height: 6),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Rs. ${f.price}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)), Text('★ ${f.rating}', style: const TextStyle(fontSize: 10, color: AppColors.muted))]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip({required String id, required String name, required String icon}) {
    final active = _category == id;
    return GestureDetector(
      onTap: () => setState(() => _category = id),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(999), border: active ? null : Border.all(color: AppColors.sand)),
        child: Text('$icon  $name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.text2)),
      ),
    );
  }
}