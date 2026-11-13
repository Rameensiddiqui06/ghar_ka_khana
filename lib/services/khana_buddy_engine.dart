import 'dart:math';

import '../models/food.dart';
import 'cart_controller.dart';

enum Craving {
  spicy('Spicy food', '🌶️'),
  comfort('Comfort food', '🍲'),
  light('Something light', '🥗'),
  surprise('Surprise me', '🎲');

  const Craving(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Limit applies to the known total: food price + delivery fee (one portion,
/// one seller).
enum Budget {
  under300(300, 'Up to Rs. 300'),
  under500(500, 'Up to Rs. 500'),
  under1000(1000, 'Up to Rs. 1,000');

  const Budget(this.limit, this.label);
  final int limit;
  final String label;
}

class KhanaBuddyRecommendation {
  final Food food;
  final List<String> reasons;
  final int foodSubtotal;
  final int deliveryFee;

  const KhanaBuddyRecommendation({
    required this.food,
    required this.reasons,
    required this.foodSubtotal,
    required this.deliveryFee,
  });

  int get total => foodSubtotal + deliveryFee;
}

/// Rule-based matching on real listing data. This is NOT generative AI.
class KhanaBuddyEngine {
  const KhanaBuddyEngine({
    this.deliveryFeePerSeller = CartController.deliveryFeePerSeller,
    this.maxResults = 6,
  });

  final int deliveryFeePerSeller;
  final int maxResults;

  // Conservative keyword lists. Edit freely to fit your menu.
  static const Map<Craving, List<String>> keywords = {
    Craving.spicy: [
      'spicy',
      'chili',
      'chilli',
      'mirch',
      'achari',
      'jalfrezi',
      'vindaloo',
      'karahi',
      'masala',
    ],
    Craving.comfort: [
      'comfort',
      'khichdi',
      'khichri',
      'daal',
      'dal',
      'haleem',
      'nihari',
      'pulao',
      'kadhi',
      'curry',
      'stew',
      'homestyle',
      'home-style',
      'kheer',
      'halwa',
    ],
    Craving.light: [
      'light',
      'salad',
      'soup',
      'grilled',
      'steamed',
      'fruit',
      'raita',
      'yogurt',
      'dahi',
      'sandwich',
      'wrap',
    ],
  };

  bool isEligible(Food f, Budget budget) =>
      f.available > 0 &&
      f.price > 0 &&
      f.price + deliveryFeePerSeller <= budget.limit;

  List<Food> eligible(List<Food> foods, Budget budget) =>
      foods.where((f) => isEligible(f, budget)).toList();

  KhanaBuddyRecommendation recommendationFor(
    Food food,
    List<String> extraReasons,
  ) =>
      _build(food, extraReasons);

  List<KhanaBuddyRecommendation> recommend(
    List<Food> foods, {
    required Craving craving,
    required Budget budget,
    Random? random,
  }) {
    final eligibleFoods = foods.where((f) => isEligible(f, budget)).toList();
    if (eligibleFoods.isEmpty) return const [];

    if (craving == Craving.surprise) {
      final pick = eligibleFoods[(random ?? Random()).nextInt(eligibleFoods.length)];
      return [
        _build(pick, [
          'Picked at random from available dishes within your budget',
        ]),
      ];
    }

    final scored = <_Scored>[];
    for (final f in eligibleFoods) {
      final m = _match(f, craving);
      if (m.isNotEmpty) scored.add(_Scored(f, m));
    }
    scored.sort((a, b) {
      final byScore = b.matches.length.compareTo(a.matches.length);
      if (byScore != 0) return byScore;
      final byRating = b.food.rating.compareTo(a.food.rating);
      if (byRating != 0) return byRating;
      final byReviews = b.food.reviews.compareTo(a.food.reviews);
      if (byReviews != 0) return byReviews;
      return a.food.price.compareTo(b.food.price);
    });

    return scored.take(maxResults).map((s) {
      final first = s.matches.first;
      return _build(s.food, [
        'Matches “${craving.label}”: “${first.keyword}” found in the '
            'dish ${first.field}',
      ]);
    }).toList();
  }

  KhanaBuddyRecommendation _build(Food f, List<String> craving) {
    return KhanaBuddyRecommendation(
      food: f,
      foodSubtotal: f.price,
      deliveryFee: deliveryFeePerSeller,
      reasons: [
        'Within your budget: Rs. ${f.price + deliveryFeePerSeller} '
            'including delivery',
        ...craving,
      ],
    );
  }

  List<_Match> _match(Food f, Craving craving) {
    final fields = <String, String>{
      'name': f.name,
      'category': f.category,
      'description': f.description,
      'ingredients': f.ingredients,
    };
    final result = <_Match>[];
    for (final kw in keywords[craving] ?? const <String>[]) {
      final re = RegExp(
        '\\b${RegExp.escape(kw)}(?:s|es)?\\b',
        caseSensitive: false,
      );
      for (final e in fields.entries) {
        if (re.hasMatch(e.value)) {
          result.add(_Match(kw, e.key));
          break; // one match per keyword; fields are checked in priority order
        }
      }
    }
    return result;
  }
}

class _Match {
  final String keyword;
  final String field;
  const _Match(this.keyword, this.field);
}

class _Scored {
  final Food food;
  final List<_Match> matches;
  _Scored(this.food, this.matches);
}