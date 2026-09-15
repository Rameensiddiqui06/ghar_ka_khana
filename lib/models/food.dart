class Food {
  final String id;
  final String name;
  final String sellerId;
  final String sellerName;
  final String category;
  final int price;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String emoji;
  final String bgColorHex; // e.g. '#B8833A'
  final String description;
  final String ingredients; // comma-separated, matches original
  final String portionSize;
  final String prepTime;
  final int available;
  final bool verified;
  final bool featured;
  final bool freshToday;

  Food({
    required this.id,
    required this.name,
    required this.sellerId,
    required this.sellerName,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.emoji,
    required this.bgColorHex,
    required this.description,
    required this.ingredients,
    required this.portionSize,
    required this.prepTime,
    required this.available,
    required this.verified,
    required this.featured,
    required this.freshToday,
  });

  factory Food.fromMap(String id, Map<String, dynamic> map) {
    return Food(
      id: id,
      name: map['name'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0) as int,
      rating: (map['rating'] ?? 0).toDouble(),
      reviews: (map['reviews'] ?? 0) as int,
      imageUrl: map['imageUrl'] ?? '',
      emoji: map['emoji'] ?? '🍽️',
      bgColorHex: map['bgColorHex'] ?? '#A68C84',
      description: map['description'] ?? '',
      ingredients: map['ingredients'] ?? '',
      portionSize: map['portionSize'] ?? '',
      prepTime: map['prepTime'] ?? '',
      available: (map['available'] ?? 0) as int,
      verified: map['verified'] ?? false,
      featured: map['featured'] ?? false,
      freshToday: map['freshToday'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'category': category,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'imageUrl': imageUrl,
      'emoji': emoji,
      'bgColorHex': bgColorHex,
      'description': description,
      'ingredients': ingredients,
      'portionSize': portionSize,
      'prepTime': prepTime,
      'available': available,
      'verified': verified,
      'featured': featured,
      'freshToday': freshToday,
    };
  }
}