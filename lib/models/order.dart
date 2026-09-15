class OrderItem {
  final String name;
  final int qty;
  final int price;

  OrderItem({required this.name, required this.qty, required this.price});

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      qty: (map['qty'] ?? 0) as int,
      price: (map['price'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'qty': qty, 'price': price};
}

class FoodOrder {
  final String id;
  final String customerId;
  final String sellerId;
  final String sellerName;
  final List<OrderItem> items;
  final int subtotal;
  final int delivery;
  final int total;
  final String status; // pending, accepted, preparing, ready, out-for-delivery, delivered, cancelled
  final String address;
  final String payment;
  final DateTime createdAt;

  FoodOrder({
    required this.id,
    required this.customerId,
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.total,
    required this.status,
    required this.address,
    required this.payment,
    required this.createdAt,
  });

  factory FoodOrder.fromMap(String id, Map<String, dynamic> map) {
    return FoodOrder(
      id: id,
      customerId: map['customerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      subtotal: (map['subtotal'] ?? 0) as int,
      delivery: (map['delivery'] ?? 0) as int,
      total: (map['total'] ?? 0) as int,
      status: map['status'] ?? 'pending',
      address: map['address'] ?? '',
      payment: map['payment'] ?? 'Cash on Delivery',
      createdAt: map['createdAt'] != null
          ? (map['createdAt']).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'delivery': delivery,
      'total': total,
      'status': status,
      'address': address,
      'payment': payment,
      'createdAt': createdAt,
    };
  }
}