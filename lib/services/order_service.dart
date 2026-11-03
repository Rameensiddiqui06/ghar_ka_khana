import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import 'cart_controller.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String methodLabel(String method) {
    switch (method) {
      case 'easypaisa':
        return 'Easypaisa';
      case 'jazzcash':
        return 'JazzCash';
      default:
        return 'Cash on Delivery';
    }
  }

  /// Creates ONE order per seller in a single atomic batch.
  /// [method] is 'cod', 'easypaisa' or 'jazzcash'.
  /// [transactionIds] maps sellerId -> TID (only for online methods).
  /// Returns the created order ids.
  Future<List<String>> placeOrders({
    required String customerId,
    required List<CartItem> items,
    required String address,
    required String phone,
    required String notes,
    required String method,
    Map<String, String> transactionIds = const {},
  }) async {
    final bySeller = <String, List<CartItem>>{};
    for (final i in items) {
      bySeller.putIfAbsent(i.food.sellerId, () => []).add(i);
    }

    final now = DateTime.now();
    final checkoutId = 'CK${now.millisecondsSinceEpoch}';
    final base = now.millisecondsSinceEpoch % 1000000;
    final batch = _db.batch();
    final ids = <String>[];

    var n = 0;
    for (final entry in bySeller.entries) {
      final list = entry.value;
      final subtotal = list.fold<int>(0, (s, i) => s + i.food.price * i.qty);
      const delivery = CartController.deliveryFeePerSeller;
      final online = method != 'cod';

      final id = 'GK${(base + n).toString().padLeft(6, '0')}';
      n++;

      final order = FoodOrder(
        id: id,
        customerId: customerId,
        sellerId: entry.key,
        sellerName: list.first.food.sellerName,
        items: list
            .map(
              (i) =>
                  OrderItem(name: i.food.name, qty: i.qty, price: i.food.price),
            )
            .toList(),
        subtotal: subtotal,
        delivery: delivery,
        total: subtotal + delivery,
        status: 'pending',
        address: address,
        payment: methodLabel(method),
        createdAt: now,
        phone: phone,
        notes: notes,
        paymentMethod: method,
        paymentStatus: online ? 'awaiting-verification' : 'unpaid',
        transactionId: online ? (transactionIds[entry.key] ?? '') : '',
        checkoutId: checkoutId,
      );

      batch.set(_db.collection('orders').doc(id), order.toMap());
      ids.add(id);
    }

    await batch.commit();
    return ids;
  }

  /// Live list of one customer's orders, newest first.
  /// (Sorted on the device so no Firestore index is needed.)
  Stream<List<FoodOrder>> streamCustomerOrders(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => FoodOrder.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Customers can only cancel while the order is still 'pending'.
  Future<void> cancelOrder(String orderId) {
    return _db.collection('orders').doc(orderId).update({
      'status': 'cancelled',
    });
  }
}
