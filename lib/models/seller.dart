class Seller {
  final String id;
  final String name;
  final String avatarUrl;
  final String coverUrl;
  final String avatarEmoji;
  final String avatarBgHex;
  final String coverEmoji;
  final String coverBgHex;
  final double rating;
  final int reviews;
  final String location;
  final String distance;
  final List<String> cuisines;
  final bool verified;
  final bool topRated;
  final String description;
  final String story;
  final String hours;
  final String days;

  Seller({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.coverUrl,
    required this.avatarEmoji,
    required this.avatarBgHex,
    required this.coverEmoji,
    required this.coverBgHex,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.distance,
    required this.cuisines,
    required this.verified,
    required this.topRated,
    required this.description,
    required this.story,
    required this.hours,
    required this.days,
  });

  factory Seller.fromMap(String id, Map<String, dynamic> map) {
    return Seller(
      id: id,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      avatarEmoji: map['avatarEmoji'] ?? '👩‍🍳',
      avatarBgHex: map['avatarBgHex'] ?? '#C2513A',
      coverEmoji: map['coverEmoji'] ?? '🍲',
      coverBgHex: map['coverBgHex'] ?? '#8B3A2C',
      rating: (map['rating'] ?? 0).toDouble(),
      reviews: (map['reviews'] ?? 0) as int,
      location: map['location'] ?? '',
      distance: map['distance'] ?? '',
      cuisines: List<String>.from(map['cuisines'] ?? []),
      verified: map['verified'] ?? false,
      topRated: map['topRated'] ?? false,
      description: map['description'] ?? '',
      story: map['story'] ?? '',
      hours: map['hours'] ?? '',
      days: map['days'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'avatarEmoji': avatarEmoji,
      'avatarBgHex': avatarBgHex,
      'coverEmoji': coverEmoji,
      'coverBgHex': coverBgHex,
      'rating': rating,
      'reviews': reviews,
      'location': location,
      'distance': distance,
      'cuisines': cuisines,
      'verified': verified,
      'topRated': topRated,
      'description': description,
      'story': story,
      'hours': hours,
      'days': days,
    };
  }
}