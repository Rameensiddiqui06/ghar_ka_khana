class FoodCategory {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final String bgColorHex;

  FoodCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    required this.bgColorHex,
  });

  factory FoodCategory.fromMap(String id, Map<String, dynamic> map) {
    return FoodCategory(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🍽️',
      imageUrl: map['imageUrl'] ?? '',
      bgColorHex: map['bgColorHex'] ?? '#A68C84',
    );
  }
}
