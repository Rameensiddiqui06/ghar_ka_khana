import 'dart:math';

import 'food_service.dart';
import 'khana_buddy_engine.dart';

/// Service boundary. Swap in an AI-backed implementation later.
abstract class KhanaBuddyRecommender {
  Future<List<KhanaBuddyRecommendation>> recommend({
    required Craving craving,
    required Budget budget,
  });
}

class RuleBasedKhanaBuddyRecommender implements KhanaBuddyRecommender {
  RuleBasedKhanaBuddyRecommender({
    FoodService? foodService,
    this.engine = const KhanaBuddyEngine(),
    Random? random,
  }) : _foodService = foodService,
       _random = random;

  final FoodService? _foodService;
  final KhanaBuddyEngine engine;
  final Random? _random;

  @override
  Future<List<KhanaBuddyRecommendation>> recommend({
    required Craving craving,
    required Budget budget,
  }) async {
    final foods = await (_foodService ?? FoodService()).getFoods();
    return engine.recommend(
      foods,
      craving: craving,
      budget: budget,
      random: _random,
    );
  }
}
