import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food.dart';
import '../models/review.dart';

class RatingStat {
  final double average;
  final int count;
  const RatingStat(this.average, this.count);
}

class ReviewService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('reviews');

  /// One review per customer per dish.
  static String docId(String foodId, String uid) => '${foodId}_$uid';

  Stream<List<Review>> streamForFood(String foodId) => _col
      .where('foodId', isEqualTo: foodId)
      .snapshots()
      .map(_toSortedList);

  Stream<List<Review>> streamForSeller(String sellerId) => _col
      .where('sellerId', isEqualTo: sellerId)
      .snapshots()
      .map(_toSortedList);

  List<Review> _toSortedList(QuerySnapshot<Map<String, dynamic>> snap) {
    final list =
        snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
    // Newest first; a null time means the write is still pending (= newest).
    list.sort((a, b) {
      final at = a.createdAt ?? DateTime.now();
      final bt = b.createdAt ?? DateTime.now();
      return bt.compareTo(at);
    });
    return list;
  }

  /// The current customer's own review of a dish, if any.
  Future<Review?> getMine(String foodId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final d = await _col.doc(docId(foodId, uid)).get();
    return d.exists ? Review.fromMap(d.id, d.data()!) : null;
  }

  /// Creates the review, or edits it if this customer already reviewed the dish.
  Future<void> submit({
    required Food food,
    required double rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please log in to write a review.');
    if (user.uid == food.sellerId) {
      throw Exception('You cannot review your own dish.');
    }

    final name = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'Customer');

    final ref = _col.doc(docId(food.id, user.uid));
    final existing = await ref.get();

    if (existing.exists) {
      await ref.update({
        'rating': rating,
        'comment': comment.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'foodId': food.id,
        'foodName': food.name,
        'sellerId': food.sellerId,
        'customerId': user.uid,
        'customerName': name,
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Seller replies to (or removes a reply from) a review.
  Future<void> reply(String reviewId, String text) async {
    final t = text.trim();
    await _col.doc(reviewId).update({
      'sellerReply': t.isEmpty ? FieldValue.delete() : t,
      'sellerReplyAt':
          t.isEmpty ? FieldValue.delete() : FieldValue.serverTimestamp(),
    });
  }

  // ---- rating aggregation (computed from reviews) ----

  static RatingStat _stat(Iterable<double> ratings) {
    if (ratings.isEmpty) return const RatingStat(0, 0);
    final sum = ratings.fold<double>(0, (a, b) => a + b);
    final avg = sum / ratings.length;
    return RatingStat(double.parse(avg.toStringAsFixed(1)), ratings.length);
  }

  Future<RatingStat> getFoodStat(String foodId) async {
    final snap = await _col.where('foodId', isEqualTo: foodId).get();
    return _stat(snap.docs.map((d) => (d.data()['rating'] ?? 0).toDouble()));
  }

  /// foodId -> rating stat, for every reviewed dish.
  Future<Map<String, RatingStat>> getAllFoodStats() async {
    final snap = await _col.get();
    final byFood = <String, List<double>>{};
    for (final d in snap.docs) {
      final data = d.data();
      final id = (data['foodId'] ?? '') as String;
      if (id.isEmpty) continue;
      byFood.putIfAbsent(id, () => []).add((data['rating'] ?? 0).toDouble());
    }
    return byFood.map((k, v) => MapEntry(k, _stat(v)));
  }

  Future<RatingStat> getSellerStat(String sellerId) async {
    final snap = await _col.where('sellerId', isEqualTo: sellerId).get();
    return _stat(snap.docs.map((d) => (d.data()['rating'] ?? 0).toDouble()));
  }

  /// sellerId -> rating stat, for every reviewed seller.
  Future<Map<String, RatingStat>> getAllSellerStats() async {
    final snap = await _col.get();
    final bySeller = <String, List<double>>{};
    for (final d in snap.docs) {
      final data = d.data();
      final id = (data['sellerId'] ?? '') as String;
      if (id.isEmpty) continue;
      bySeller.putIfAbsent(id, () => []).add((data['rating'] ?? 0).toDouble());
    }
    return bySeller.map((k, v) => MapEntry(k, _stat(v)));
  }
}