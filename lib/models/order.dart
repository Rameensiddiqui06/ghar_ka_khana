

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
  final String
  status; // pending, accepted, preparing, ready, out-for-delivery, delivered, cancelled
  final String address;
  final String payment; // display label, e.g. "Cash on Delivery"
  final DateTime createdAt;

  // New checkout fields (all have defaults so old documents still load).
  final String phone;
  final String notes;
  final String paymentMethod; // cod, easypaisa, jazzcash
  final String paymentStatus; // unpaid, awaiting-verification, paid
  final String transactionId;
  final String checkoutId; // same for all orders created in one checkout

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
    this.phone = '',
    this.notes = '',
    this.paymentMethod = 'cod',
    this.paymentStatus = 'unpaid',
    this.transactionId = '',
    this.checkoutId = '',
  });

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'paid':
        return 'Paid';
      case 'awaiting-verification':
        return 'Payment awaiting verification';
      default:
        return paymentMethod == 'cod' ? 'Pay on delivery' : 'Unpaid';
    }
  }

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
      phone: map['phone'] ?? '',
      notes: map['notes'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'cod',
      paymentStatus: map['paymentStatus'] ?? 'unpaid',
      transactionId: map['transactionId'] ?? '',
      checkoutId: map['checkoutId'] ?? '',
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
      'phone': phone,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'checkoutId': checkoutId,
    };
  }
}
