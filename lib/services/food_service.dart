import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food.dart';
import '../models/seller.dart';
import '../models/category.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Food>> getFoods() async {
    final snapshot = await _firestore.collection('foods').get();
    return snapshot.docs.map((doc) => Food.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Seller>> getSellers() async {
    final snapshot = await _firestore.collection('sellers').get();
    return snapshot.docs.map((doc) => Seller.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<FoodCategory>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => FoodCategory.fromMap(doc.id, doc.data())).toList();
  }

  Future<Food?> getFoodById(String id) async {
    final doc = await _firestore.collection('foods').doc(id).get();
    if (!doc.exists) return null;
    return Food.fromMap(doc.id, doc.data()!);
  }

  Future<Seller?> getSellerById(String id) async {
    final doc = await _firestore.collection('sellers').doc(id).get();
    if (!doc.exists) return null;
    return Seller.fromMap(doc.id, doc.data()!);
  }

  Future<List<Food>> getFoodsBySeller(String sellerId) async {
    final snapshot = await _firestore
        .collection('foods')
        .where('sellerId', isEqualTo: sellerId)
        .get();
    return snapshot.docs.map((doc) => Food.fromMap(doc.id, doc.data())).toList();
  }
}