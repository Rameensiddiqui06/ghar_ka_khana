import 'package:flutter/foundation.dart';
import '../models/food.dart';

class CartItem {
  final Food food;
  int qty;
  CartItem(this.food, this.qty);
}

/// Holds the cart for the whole customer app. Screens listen to it with
/// AnimatedBuilder(animation: cart, ...) so they update live, even on pushed
/// routes.
class CartController extends ChangeNotifier {
  static const int deliveryFeePerSeller = 50;

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.qty);
  int get subtotal =>
      _items.values.fold(0, (sum, i) => sum + i.food.price * i.qty);
  int get sellerCount =>
      _items.values.map((i) => i.food.sellerId).toSet().length;
  int get deliveryFee => sellerCount * deliveryFeePerSeller;
  int get total => subtotal + deliveryFee;

  int _maxFor(Food f) => f.available > 0 ? f.available : 1;

  void add(Food food, int qty) {
    final existing = _items[food.id];
    if (existing != null) {
      existing.qty = (existing.qty + qty).clamp(1, _maxFor(food));
    } else {
      _items[food.id] = CartItem(food, qty.clamp(1, _maxFor(food)));
    }
    notifyListeners();
  }

  void setQty(String foodId, int qty) {
    final item = _items[foodId];
    if (item == null) return;
    if (qty <= 0) {
      _items.remove(foodId);
    } else {
      item.qty = qty.clamp(1, _maxFor(item.food));
    }
    notifyListeners();
  }

  void remove(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
