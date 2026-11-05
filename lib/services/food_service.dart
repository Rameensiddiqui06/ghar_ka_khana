



// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/food.dart';
// import '../models/seller.dart';
// import '../models/category.dart';

// class FoodService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Stock shown to customers for a seller dish that is switched "In Stock".
//   static const int _inStockQty = 20;

//   Future<List<Food>> getFoods() async {
//     // 1) Seed dishes (top-level "foods")
//     final seeded = await _firestore.collection('foods').get();
//     final foods =
//         seeded.docs.map((d) => Food.fromMap(d.id, d.data())).toList();

//     // 2) Dishes sellers add in kitchens/{sellerUid}/menu
//     final menu = await _firestore.collectionGroup('menu').get();
//     if (menu.docs.isEmpty) return _dedupe(foods);

//     final catKeys = await _categoryKeys();

//     final sellerIds = <String>{};
//     for (final doc in menu.docs) {
//       final id = doc.reference.parent.parent?.id;
//       if (id != null) sellerIds.add(id);
//     }
//     final names = await _sellerNames(sellerIds);

//     for (final doc in menu.docs) {
//       final sellerId = doc.reference.parent.parent?.id;
//       if (sellerId == null) continue;
//       foods.add(
//         Food.fromMap(
//           doc.id,
//           _menuToFoodMap(
//             sellerId,
//             names[sellerId] ?? 'Home Kitchen',
//             doc.data(),
//             catKeys,
//           ),
//         ),
//       );
//     }
//     return _dedupe(foods);
//   }

//   /// Same seller + same dish name = same dish. Keeps the first one.
//   List<Food> _dedupe(List<Food> foods) {
//     final seen = <String>{};
//     final result = <Food>[];
//     for (final f in foods) {
//       final key = '${f.sellerId}|${f.name.toLowerCase().trim()}';
//       if (seen.add(key)) result.add(f);
//     }
//     return result;
//   }

//   Future<List<Seller>> getSellers() async {
//     final snapshot = await _firestore.collection('sellers').get();
//     return snapshot.docs
//         .map((doc) => Seller.fromMap(doc.id, doc.data()))
//         .toList();
//   }

//   Future<List<FoodCategory>> getCategories() async {
//     final snapshot = await _firestore.collection('categories').get();
//     return snapshot.docs
//         .map((doc) => FoodCategory.fromMap(doc.id, doc.data()))
//         .toList();
//   }

//   Future<Food?> getFoodById(String id) async {
//     final doc = await _firestore.collection('foods').doc(id).get();
//     if (doc.exists) return Food.fromMap(doc.id, doc.data()!);

//     final menu = await _firestore.collectionGroup('menu').get();
//     for (final d in menu.docs) {
//       if (d.id == id) {
//         final sellerId = d.reference.parent.parent?.id;
//         if (sellerId == null) return null;
//         final names = await _sellerNames({sellerId});
//         final catKeys = await _categoryKeys();
//         return Food.fromMap(
//           d.id,
//           _menuToFoodMap(
//             sellerId,
//             names[sellerId] ?? 'Home Kitchen',
//             d.data(),
//             catKeys,
//           ),
//         );
//       }
//     }
//     return null;
//   }

//   Future<Seller?> getSellerById(String id) async {
//     final doc = await _firestore.collection('sellers').doc(id).get();
//     if (!doc.exists) return null;
//     return Seller.fromMap(doc.id, doc.data()!);
//   }

//   Future<List<Food>> getFoodsBySeller(String sellerId) async {
//     final all = await getFoods();
//     return all.where((f) => f.sellerId == sellerId).toList();
//   }

//   // ---------- helpers ----------

//   /// Maps lowercase words (category names and ids) to the category id, e.g.
//   /// {'biryani': 'biryani', 'desserts': 'dessert', ...}
//   Future<Map<String, String>> _categoryKeys() async {
//     final snap = await _firestore.collection('categories').get();
//     final keys = <String, String>{};
//     for (final d in snap.docs) {
//       final id = d.id;
//       final name = ((d.data()['name'] ?? '') as String).toLowerCase().trim();
//       void add(String k) {
//         if (k.length >= 3) keys[k] = id;
//       }

//       add(id.toLowerCase());
//       add(name);
//       if (name.endsWith('s')) add(name.substring(0, name.length - 1));
//     }
//     return keys;
//   }

//   /// Picks the customer category id by looking for a category word in the
//   /// dish name first, then in the seller's category.
//   String _resolveCategory(
//     String dishName,
//     String sellerCategory,
//     Map<String, String> keys,
//   ) {
//     final name = dishName.toLowerCase();
//     for (final e in keys.entries) {
//       if (name.contains(e.key)) return e.value;
//     }
//     final cat = sellerCategory.toLowerCase();
//     for (final e in keys.entries) {
//       if (cat.contains(e.key)) return e.value;
//     }
//     return sellerCategory.toLowerCase();
//   }

//   Future<Map<String, String>> _sellerNames(Set<String> ids) async {
//     final result = <String, String>{};
//     await Future.wait(ids.map((id) async {
//       try {
//         final doc = await _firestore.collection('kitchens').doc(id).get();
//         final data = doc.data();
//         final name = (data?['kitchenName'] ?? data?['name'] ?? '') as String;
//         result[id] = name.isNotEmpty ? name : 'Home Kitchen';
//       } catch (_) {
//         result[id] = 'Home Kitchen';
//       }
//     }));
//     return result;
//   }

//   static int _toInt(dynamic v) => v is num ? v.toInt() : 0;

//   /// Converts a seller menu document into the shape Food.fromMap expects.
//   Map<String, dynamic> _menuToFoodMap(
//     String sellerId,
//     String sellerName,
//     Map<String, dynamic> m,
//     Map<String, String> catKeys,
//   ) {
//     final inStock = m['isAvailable'] != false;
//     final dishName = (m['name'] ?? '') as String;
//     return {
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'name': dishName,
//       'price': _toInt(m['price']),
//       'category': _resolveCategory(
//         dishName,
//         (m['category'] ?? '') as String,
//         catKeys,
//       ),
//       'description': m['description'] ?? '',
//       'imageUrl': m['imageUrl'] ?? '',
//       'ingredients': m['ingredients'] ?? '',
//       'portionSize': m['servingSize'] ?? '',
//       'prepTime': m['prepTime'] ?? '',
//       'rating': 0,
//       'reviews': 0,
//       'available': inStock ? _inStockQty : 0,
//       'verified': true,
//       'featured': false,
//       'freshToday': m['isTodaysMenu'] ?? false,
//     };
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/food.dart';
// import '../models/seller.dart';
// import '../models/category.dart';
// import 'review_service.dart';

// class FoodService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ReviewService _reviewService = ReviewService();

//   /// Stock shown to customers for a seller dish that is switched "In Stock".
//   static const int _inStockQty = 20;

//   /// Dishes with ratings calculated from real reviews.
//   Future<List<Food>> getFoods() async {
//     final foods = await _getFoodsRaw();
//     try {
//       final stats = await _reviewService.getAllFoodStats();
//       return foods.map((f) {
//         final s = stats[f.id];
//         return s == null ? f : f.withRating(s.average, s.count);
//       }).toList();
//     } catch (_) {
//       return foods; // if reviews can't load, still show the dishes
//     }
//   }

//   Future<List<Food>> _getFoodsRaw() async {
//     // 1) Seed dishes (top-level "foods")
//     final seeded = await _firestore.collection('foods').get();
//     final foods =
//         seeded.docs.map((d) => Food.fromMap(d.id, d.data())).toList();

//     // 2) Dishes sellers add in kitchens/{sellerUid}/menu
//     final menu = await _firestore.collectionGroup('menu').get();
//     if (menu.docs.isEmpty) return _dedupe(foods);

//     final catKeys = await _categoryKeys();

//     final sellerIds = <String>{};
//     for (final doc in menu.docs) {
//       final id = doc.reference.parent.parent?.id;
//       if (id != null) sellerIds.add(id);
//     }
//     final names = await _sellerNames(sellerIds);

//     for (final doc in menu.docs) {
//       final sellerId = doc.reference.parent.parent?.id;
//       if (sellerId == null) continue;
//       foods.add(
//         Food.fromMap(
//           doc.id,
//           _menuToFoodMap(
//             sellerId,
//             names[sellerId] ?? 'Home Kitchen',
//             doc.data(),
//             catKeys,
//           ),
//         ),
//       );
//     }
//     return _dedupe(foods);
//   }

//   /// Same seller + same dish name = same dish. Keeps the first one.
//   List<Food> _dedupe(List<Food> foods) {
//     final seen = <String>{};
//     final result = <Food>[];
//     for (final f in foods) {
//       final key = '${f.sellerId}|${f.name.toLowerCase().trim()}';
//       if (seen.add(key)) result.add(f);
//     }
//     return result;
//   }

//   Future<List<Seller>> getSellers() async {
//     final snapshot = await _firestore.collection('sellers').get();
//     final sellers = snapshot.docs
//         .map((doc) => Seller.fromMap(doc.id, doc.data()))
//         .toList();
//     try {
//       final stats = await _reviewService.getAllSellerStats();
//       return sellers.map((s) {
//         final st = stats[s.id];
//         return st == null ? s : s.withRating(st.average, st.count);
//       }).toList();
//     } catch (_) {
//       return sellers;
//     }
//   }

//   Future<List<FoodCategory>> getCategories() async {
//     final snapshot = await _firestore.collection('categories').get();
//     return snapshot.docs
//         .map((doc) => FoodCategory.fromMap(doc.id, doc.data()))
//         .toList();
//   }

//   Future<Food?> getFoodById(String id) async {
//     final food = await _getFoodByIdRaw(id);
//     if (food == null) return null;
//     try {
//       final s = await _reviewService.getFoodStat(id);
//       return s.count == 0 ? food : food.withRating(s.average, s.count);
//     } catch (_) {
//       return food;
//     }
//   }

//   Future<Food?> _getFoodByIdRaw(String id) async {
//     final doc = await _firestore.collection('foods').doc(id).get();
//     if (doc.exists) return Food.fromMap(doc.id, doc.data()!);

//     final menu = await _firestore.collectionGroup('menu').get();
//     for (final d in menu.docs) {
//       if (d.id == id) {
//         final sellerId = d.reference.parent.parent?.id;
//         if (sellerId == null) return null;
//         final names = await _sellerNames({sellerId});
//         final catKeys = await _categoryKeys();
//         return Food.fromMap(
//           d.id,
//           _menuToFoodMap(
//             sellerId,
//             names[sellerId] ?? 'Home Kitchen',
//             d.data(),
//             catKeys,
//           ),
//         );
//       }
//     }
//     return null;
//   }

//   Future<Seller?> getSellerById(String id) async {
//     final doc = await _firestore.collection('sellers').doc(id).get();
//     if (!doc.exists) return null;
//     final seller = Seller.fromMap(doc.id, doc.data()!);
//     try {
//       final st = await _reviewService.getSellerStat(id);
//       return st.count == 0 ? seller : seller.withRating(st.average, st.count);
//     } catch (_) {
//       return seller;
//     }
//   }

//   Future<List<Food>> getFoodsBySeller(String sellerId) async {
//     final all = await getFoods();
//     return all.where((f) => f.sellerId == sellerId).toList();
//   }

//   // ---------- helpers ----------

//   /// Maps lowercase words (category names and ids) to the category id, e.g.
//   /// {'biryani': 'biryani', 'desserts': 'dessert', ...}
//   Future<Map<String, String>> _categoryKeys() async {
//     final snap = await _firestore.collection('categories').get();
//     final keys = <String, String>{};
//     for (final d in snap.docs) {
//       final id = d.id;
//       final name = ((d.data()['name'] ?? '') as String).toLowerCase().trim();
//       void add(String k) {
//         if (k.length >= 3) keys[k] = id;
//       }

//       add(id.toLowerCase());
//       add(name);
//       if (name.endsWith('s')) add(name.substring(0, name.length - 1));
//     }
//     return keys;
//   }

//   /// Picks the customer category id by looking for a category word in the
//   /// dish name first, then in the seller's category.
//   String _resolveCategory(
//     String dishName,
//     String sellerCategory,
//     Map<String, String> keys,
//   ) {
//     final name = dishName.toLowerCase();
//     for (final e in keys.entries) {
//       if (name.contains(e.key)) return e.value;
//     }
//     final cat = sellerCategory.toLowerCase();
//     for (final e in keys.entries) {
//       if (cat.contains(e.key)) return e.value;
//     }
//     return sellerCategory.toLowerCase();
//   }

//   Future<Map<String, String>> _sellerNames(Set<String> ids) async {
//     final result = <String, String>{};
//     await Future.wait(ids.map((id) async {
//       try {
//         final doc = await _firestore.collection('kitchens').doc(id).get();
//         final data = doc.data();
//         final name = (data?['kitchenName'] ?? data?['name'] ?? '') as String;
//         result[id] = name.isNotEmpty ? name : 'Home Kitchen';
//       } catch (_) {
//         result[id] = 'Home Kitchen';
//       }
//     }));
//     return result;
//   }

//   static int _toInt(dynamic v) => v is num ? v.toInt() : 0;

//   /// Converts a seller menu document into the shape Food.fromMap expects.
//   Map<String, dynamic> _menuToFoodMap(
//     String sellerId,
//     String sellerName,
//     Map<String, dynamic> m,
//     Map<String, String> catKeys,
//   ) {
//     final inStock = m['isAvailable'] != false;
//     final dishName = (m['name'] ?? '') as String;
//     return {
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'name': dishName,
//       'price': _toInt(m['price']),
//       'category': _resolveCategory(
//         dishName,
//         (m['category'] ?? '') as String,
//         catKeys,
//       ),
//       'description': m['description'] ?? '',
//       'imageUrl': m['imageUrl'] ?? '',
//       'ingredients': m['ingredients'] ?? '',
//       'portionSize': m['servingSize'] ?? '',
//       'prepTime': m['prepTime'] ?? '',
//       'rating': 0,
//       'reviews': 0,
//       'available': inStock ? _inStockQty : 0,
//       'verified': true,
//       'featured': false,
//       'freshToday': m['isTodaysMenu'] ?? false,
//     };
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/food.dart';
// import '../models/seller.dart';
// import '../models/category.dart';
// import 'review_service.dart';

// class FoodService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ReviewService _reviewService = ReviewService();

//   /// Stock shown to customers for a seller dish that is switched "In Stock".
//   static const int _inStockQty = 20;

//   /// Dishes with ratings calculated from real reviews.
//   Future<List<Food>> getFoods() async {
//     final foods = await _getFoodsRaw();
//     try {
//       final stats = await _reviewService.getAllFoodStats();
//       return foods.map((f) {
//         final s = stats[f.id];
//         return s == null ? f : f.withRating(s.average, s.count);
//       }).toList();
//     } catch (_) {
//       return foods; // if reviews can't load, still show the dishes
//     }
//   }

//   Future<List<Food>> _getFoodsRaw() async {
//     // Demo dishes (top-level "foods" collection) are no longer shown.
//     final foods = <Food>[];

//     // Dishes sellers add in kitchens/{sellerUid}/menu
//     final menu = await _firestore.collectionGroup('menu').get();
//     if (menu.docs.isEmpty) return foods;

//     final catKeys = await _categoryKeys();

//     final sellerIds = <String>{};
//     for (final doc in menu.docs) {
//       final id = doc.reference.parent.parent?.id;
//       if (id != null) sellerIds.add(id);
//     }
//     final names = await _sellerNames(sellerIds);

//     for (final doc in menu.docs) {
//       final sellerId = doc.reference.parent.parent?.id;
//       if (sellerId == null) continue;
//       foods.add(
//         Food.fromMap(
//           doc.id,
//           _menuToFoodMap(
//             sellerId,
//             names[sellerId] ?? 'Home Kitchen',
//             doc.data(),
//             catKeys,
//           ),
//         ),
//       );
//     }
//     return _dedupe(foods);
//   }

//   /// Same seller + same dish name = same dish. Keeps the first one.
//   List<Food> _dedupe(List<Food> foods) {
//     final seen = <String>{};
//     final result = <Food>[];
//     for (final f in foods) {
//       final key = '${f.sellerId}|${f.name.toLowerCase().trim()}';
//       if (seen.add(key)) result.add(f);
//     }
//     return result;
//   }

//   Future<List<Seller>> getSellers() async {
//     final snapshot = await _firestore.collection('sellers').get();
//     final sellers = snapshot.docs
//         .map((doc) => Seller.fromMap(doc.id, doc.data()))
//         .toList();
//     try {
//       final stats = await _reviewService.getAllSellerStats();
//       return sellers.map((s) {
//         final st = stats[s.id];
//         return st == null ? s : s.withRating(st.average, st.count);
//       }).toList();
//     } catch (_) {
//       return sellers;
//     }
//   }

//   Future<List<FoodCategory>> getCategories() async {
//     final snapshot = await _firestore.collection('categories').get();
//     return snapshot.docs
//         .map((doc) => FoodCategory.fromMap(doc.id, doc.data()))
//         .toList();
//   }

//   Future<Food?> getFoodById(String id) async {
//     final food = await _getFoodByIdRaw(id);
//     if (food == null) return null;
//     try {
//       final s = await _reviewService.getFoodStat(id);
//       return s.count == 0 ? food : food.withRating(s.average, s.count);
//     } catch (_) {
//       return food;
//     }
//   }

//   Future<Food?> _getFoodByIdRaw(String id) async {
//     final doc = await _firestore.collection('foods').doc(id).get();
//     if (doc.exists) return Food.fromMap(doc.id, doc.data()!);

//     final menu = await _firestore.collectionGroup('menu').get();
//     for (final d in menu.docs) {
//       if (d.id == id) {
//         final sellerId = d.reference.parent.parent?.id;
//         if (sellerId == null) return null;
//         final names = await _sellerNames({sellerId});
//         final catKeys = await _categoryKeys();
//         return Food.fromMap(
//           d.id,
//           _menuToFoodMap(
//             sellerId,
//             names[sellerId] ?? 'Home Kitchen',
//             d.data(),
//             catKeys,
//           ),
//         );
//       }
//     }
//     return null;
//   }

//   Future<Seller?> getSellerById(String id) async {
//     final doc = await _firestore.collection('sellers').doc(id).get();
//     if (!doc.exists) return null;
//     final seller = Seller.fromMap(doc.id, doc.data()!);
//     try {
//       final st = await _reviewService.getSellerStat(id);
//       return st.count == 0 ? seller : seller.withRating(st.average, st.count);
//     } catch (_) {
//       return seller;
//     }
//   }

//   Future<List<Food>> getFoodsBySeller(String sellerId) async {
//     final all = await getFoods();
//     return all.where((f) => f.sellerId == sellerId).toList();
//   }

//   // ---------- helpers ----------

//   /// Maps lowercase words (category names and ids) to the category id, e.g.
//   /// {'biryani': 'biryani', 'desserts': 'dessert', ...}
//   Future<Map<String, String>> _categoryKeys() async {
//     final snap = await _firestore.collection('categories').get();
//     final keys = <String, String>{};
//     for (final d in snap.docs) {
//       final id = d.id;
//       final name = ((d.data()['name'] ?? '') as String).toLowerCase().trim();
//       void add(String k) {
//         if (k.length >= 3) keys[k] = id;
//       }

//       add(id.toLowerCase());
//       add(name);
//       if (name.endsWith('s')) add(name.substring(0, name.length - 1));
//     }
//     return keys;
//   }

//   /// Picks the customer category id. The seller's chosen category wins;
//   /// older dishes fall back to matching words in the dish name.
//   String _resolveCategory(
//     String dishName,
//     String sellerCategory,
//     Map<String, String> keys,
//   ) {
//     final exact = keys[sellerCategory.toLowerCase().trim()];
//     if (exact != null) return exact;

//     final name = dishName.toLowerCase();
//     for (final e in keys.entries) {
//       if (name.contains(e.key)) return e.value;
//     }
//     final cat = sellerCategory.toLowerCase();
//     for (final e in keys.entries) {
//       if (cat.contains(e.key)) return e.value;
//     }
//     return sellerCategory.toLowerCase();
//   }

//   Future<Map<String, String>> _sellerNames(Set<String> ids) async {
//     final result = <String, String>{};
//     await Future.wait(ids.map((id) async {
//       try {
//         final doc = await _firestore.collection('kitchens').doc(id).get();
//         final data = doc.data();
//         final name = (data?['kitchenName'] ?? data?['name'] ?? '') as String;
//         result[id] = name.isNotEmpty ? name : 'Home Kitchen';
//       } catch (_) {
//         result[id] = 'Home Kitchen';
//       }
//     }));
//     return result;
//   }

//   static int _toInt(dynamic v) => v is num ? v.toInt() : 0;

//   /// Converts a seller menu document into the shape Food.fromMap expects.
//   Map<String, dynamic> _menuToFoodMap(
//     String sellerId,
//     String sellerName,
//     Map<String, dynamic> m,
//     Map<String, String> catKeys,
//   ) {
//     final inStock = m['isAvailable'] != false;
//     final dishName = (m['name'] ?? '') as String;
//     return {
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'name': dishName,
//       'price': _toInt(m['price']),
//       'category': _resolveCategory(
//         dishName,
//         (m['category'] ?? '') as String,
//         catKeys,
//       ),
//       'description': m['description'] ?? '',
//       'imageUrl': m['imageUrl'] ?? '',
//       'ingredients': m['ingredients'] ?? '',
//       'portionSize': m['servingSize'] ?? '',
//       'prepTime': m['prepTime'] ?? '',
//       'rating': 0,
//       'reviews': 0,
//       'available': inStock ? _inStockQty : 0,
//       'verified': true,
//       'featured': false,
//       'freshToday': m['isTodaysMenu'] ?? false,
//     };
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food.dart';
import '../models/seller.dart';
import '../models/category.dart';
import 'review_service.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReviewService _reviewService = ReviewService();

  /// Stock shown to customers for a seller dish that is switched "In Stock".
  static const int _inStockQty = 20;

  /// Dishes with ratings calculated from real reviews.
  Future<List<Food>> getFoods() async {
    final foods = await _getFoodsRaw();
    try {
      final stats = await _reviewService.getAllFoodStats();
      return foods.map((f) {
        final s = stats[f.id];
        return s == null ? f : f.withRating(s.average, s.count);
      }).toList();
    } catch (_) {
      return foods; // if reviews can't load, still show the dishes
    }
  }

  Future<List<Food>> _getFoodsRaw() async {
    // Demo dishes (top-level "foods" collection) are no longer shown.
    final foods = <Food>[];

    // Dishes sellers add in kitchens/{sellerUid}/menu
    final menu = await _firestore.collectionGroup('menu').get();
    if (menu.docs.isEmpty) return foods;

    final catKeys = await _categoryKeys();

    final sellerIds = <String>{};
    for (final doc in menu.docs) {
      final id = doc.reference.parent.parent?.id;
      if (id != null) sellerIds.add(id);
    }
    final names = await _sellerNames(sellerIds);

    for (final doc in menu.docs) {
      final sellerId = doc.reference.parent.parent?.id;
      if (sellerId == null) continue;
      foods.add(
        Food.fromMap(
          doc.id,
          _menuToFoodMap(
            sellerId,
            names[sellerId] ?? 'Home Kitchen',
            doc.data(),
            catKeys,
          ),
        ),
      );
    }
    return _dedupe(foods);
  }

  /// Same seller + same dish name = same dish. Keeps the first one.
  List<Food> _dedupe(List<Food> foods) {
    final seen = <String>{};
    final result = <Food>[];
    for (final f in foods) {
      final key = '${f.sellerId}|${f.name.toLowerCase().trim()}';
      if (seen.add(key)) result.add(f);
    }
    return result;
  }

  Future<List<Seller>> getSellers() async {
    final snapshot = await _firestore.collection('sellers').get();
    final sellers = snapshot.docs
        .map((doc) => Seller.fromMap(doc.id, doc.data()))
        .toList();
    try {
      final stats = await _reviewService.getAllSellerStats();
      return sellers.map((s) {
        final st = stats[s.id];
        return st == null ? s : s.withRating(st.average, st.count);
      }).toList();
    } catch (_) {
      return sellers;
    }
  }

  Future<List<FoodCategory>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) => FoodCategory.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<Food?> getFoodById(String id) async {
    final food = await _getFoodByIdRaw(id);
    if (food == null) return null;
    try {
      final s = await _reviewService.getFoodStat(id);
      return s.count == 0 ? food : food.withRating(s.average, s.count);
    } catch (_) {
      return food;
    }
  }

  Future<Food?> _getFoodByIdRaw(String id) async {
    final doc = await _firestore.collection('foods').doc(id).get();
    if (doc.exists) return Food.fromMap(doc.id, doc.data()!);

    final menu = await _firestore.collectionGroup('menu').get();
    for (final d in menu.docs) {
      if (d.id == id) {
        final sellerId = d.reference.parent.parent?.id;
        if (sellerId == null) return null;
        final names = await _sellerNames({sellerId});
        final catKeys = await _categoryKeys();
        return Food.fromMap(
          d.id,
          _menuToFoodMap(
            sellerId,
            names[sellerId] ?? 'Home Kitchen',
            d.data(),
            catKeys,
          ),
        );
      }
    }
    return null;
  }

  /// Loads a seller for checkout / seller pages.
  ///
  /// Sellers edit their profile in `kitchens/{uid}` (including their
  /// Easypaisa / JazzCash numbers), so that document is the source of truth
  /// for name and payment details. A legacy `sellers/{uid}` document, if it
  /// exists, supplies everything else (avatar, cover, rating, etc.).
  Future<Seller?> getSellerById(String id) async {
    final results = await Future.wait([
      _firestore.collection('sellers').doc(id).get(),
      _firestore.collection('kitchens').doc(id).get(),
    ]);
    final sellerDoc = results[0];
    final kitchenDoc = results[1];
    if (!sellerDoc.exists && !kitchenDoc.exists) return null;

    final data = <String, dynamic>{...?sellerDoc.data()};
    final k = kitchenDoc.data();
    if (k != null) {
      final kitchenName = (k['kitchenName'] ?? k['name'] ?? '').toString();
      if (kitchenName.isNotEmpty) data['name'] = kitchenName;

      final about = (k['about'] ?? '').toString();
      if (about.isNotEmpty && (data['description'] ?? '').toString().isEmpty) {
        data['description'] = about;
      }
      final location = (k['location'] ?? '').toString();
      if (location.isNotEmpty && (data['location'] ?? '').toString().isEmpty) {
        data['location'] = location;
      }
      final hours = (k['hours'] ?? '').toString();
      if (hours.isNotEmpty && (data['hours'] ?? '').toString().isEmpty) {
        data['hours'] = hours;
      }

      for (final key in ['easypaisaNumber', 'jazzcashNumber', 'accountTitle']) {
        // Kitchen value always wins, even when empty, so that a seller who
        // removes a number really stops accepting that method.
        if (k.containsKey(key)) data[key] = (k[key] ?? '').toString();
      }
    }

    final seller = Seller.fromMap(id, data);
    try {
      final st = await _reviewService.getSellerStat(id);
      return st.count == 0 ? seller : seller.withRating(st.average, st.count);
    } catch (_) {
      return seller;
    }
  }

  Future<List<Food>> getFoodsBySeller(String sellerId) async {
    final all = await getFoods();
    return all.where((f) => f.sellerId == sellerId).toList();
  }

  // ---------- helpers ----------

  /// Maps lowercase words (category names and ids) to the category id, e.g.
  /// {'biryani': 'biryani', 'desserts': 'dessert', ...}
  Future<Map<String, String>> _categoryKeys() async {
    final snap = await _firestore.collection('categories').get();
    final keys = <String, String>{};
    for (final d in snap.docs) {
      final id = d.id;
      final name = ((d.data()['name'] ?? '') as String).toLowerCase().trim();
      void add(String k) {
        if (k.length >= 3) keys[k] = id;
      }

      add(id.toLowerCase());
      add(name);
      if (name.endsWith('s')) add(name.substring(0, name.length - 1));
    }
    return keys;
  }

  /// Picks the customer category id. The seller's chosen category wins;
  /// older dishes fall back to matching words in the dish name.
  String _resolveCategory(
    String dishName,
    String sellerCategory,
    Map<String, String> keys,
  ) {
    final exact = keys[sellerCategory.toLowerCase().trim()];
    if (exact != null) return exact;

    final name = dishName.toLowerCase();
    for (final e in keys.entries) {
      if (name.contains(e.key)) return e.value;
    }
    final cat = sellerCategory.toLowerCase();
    for (final e in keys.entries) {
      if (cat.contains(e.key)) return e.value;
    }
    return sellerCategory.toLowerCase();
  }

  Future<Map<String, String>> _sellerNames(Set<String> ids) async {
    final result = <String, String>{};
    await Future.wait(ids.map((id) async {
      try {
        final doc = await _firestore.collection('kitchens').doc(id).get();
        final data = doc.data();
        final name = (data?['kitchenName'] ?? data?['name'] ?? '') as String;
        result[id] = name.isNotEmpty ? name : 'Home Kitchen';
      } catch (_) {
        result[id] = 'Home Kitchen';
      }
    }));
    return result;
  }

  static int _toInt(dynamic v) => v is num ? v.toInt() : 0;

  /// Converts a seller menu document into the shape Food.fromMap expects.
  Map<String, dynamic> _menuToFoodMap(
    String sellerId,
    String sellerName,
    Map<String, dynamic> m,
    Map<String, String> catKeys,
  ) {
    final inStock = m['isAvailable'] != false;
    final dishName = (m['name'] ?? '') as String;
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': dishName,
      'price': _toInt(m['price']),
      'category': _resolveCategory(
        dishName,
        (m['category'] ?? '') as String,
        catKeys,
      ),
      'description': m['description'] ?? '',
      'imageUrl': m['imageUrl'] ?? '',
      'ingredients': m['ingredients'] ?? '',
      'portionSize': m['servingSize'] ?? '',
      'prepTime': m['prepTime'] ?? '',
      'rating': 0,
      'reviews': 0,
      'available': inStock ? _inStockQty : 0,
      'verified': true,
      'featured': false,
      'freshToday': m['isTodaysMenu'] ?? false,
    };
  }
}