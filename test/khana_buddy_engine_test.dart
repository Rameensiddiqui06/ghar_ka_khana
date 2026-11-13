import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_khana/models/food.dart';
import 'package:ghar_ka_khana/services/khana_buddy_engine.dart';

Food food(
  String id, {
  String name = 'Dish',
  String category = '',
  String description = '',
  String ingredients = '',
  int price = 200,
  int available = 5,
  double rating = 4.0,
  int reviews = 10,
}) => Food(
  id: id,
  name: name,
  sellerId: 's1',
  sellerName: 'Seller',
  category: category,
  price: price,
  rating: rating,
  reviews: reviews,
  imageUrl: '',
  emoji: '🍽️',
  bgColorHex: '#A68C84',
  description: description,
  ingredients: ingredients,
  portionSize: '',
  prepTime: '',
  available: available,
  verified: false,
  featured: false,
  freshToday: false,
);

void main() {
  const engine = KhanaBuddyEngine();

  group('budget', () {
    test('includes delivery fee in the limit', () {
      final foods = [
        food('a', name: 'Spicy A', price: 250), // 300 total -> in
        food('b', name: 'Spicy B', price: 251), // 301 total -> out
      ];
      final r = engine.recommend(
        foods,
        craving: Craving.spicy,
        budget: Budget.under300,
      );
      expect(r.map((e) => e.food.id), ['a']);
      expect(r.first.total, 300);
      expect(r.first.deliveryFee, 50);
    });

    test('excludes sold out and zero-price dishes', () {
      final foods = [
        food('a', name: 'Spicy A', available: 0),
        food('b', name: 'Spicy B', price: 0),
      ];
      expect(
        engine.recommend(
          foods,
          craving: Craving.spicy,
          budget: Budget.under1000,
        ),
        isEmpty,
      );
    });
  });

  group('craving matching', () {
    test('matches on name, description or ingredients', () {
      final foods = [
        food('a', name: 'Chicken Karahi'),
        food('b', description: 'Made with fresh chilli'),
        food('c', name: 'Plain Rice'),
      ];
      final ids = engine
          .recommend(foods, craving: Craving.spicy, budget: Budget.under500)
          .map((e) => e.food.id)
          .toSet();
      expect(ids, {'a', 'b'});
    });

    test('uses word boundaries (dalia is not dal)', () {
      final foods = [food('a', name: 'Sweet Dalia')];
      expect(
        engine.recommend(
          foods,
          craving: Craving.comfort,
          budget: Budget.under500,
        ),
        isEmpty,
      );
    });

    test('ranks by rating when match counts are equal', () {
      final foods = [
        food('a', name: 'Spicy A', rating: 3.5),
        food('b', name: 'Spicy B', rating: 4.8),
      ];
      final r = engine.recommend(
        foods,
        craving: Craving.spicy,
        budget: Budget.under500,
      );
      expect(r.first.food.id, 'b');
    });
  });

  group('surprise me', () {
    test('returns one eligible dish only', () {
      final foods = [
        food('a', price: 100),
        food('b', price: 280),
        food('c', price: 400), // too expensive for 300
        food('d', available: 0),
      ];
      final r = engine.recommend(
        foods,
        craving: Craving.surprise,
        budget: Budget.under300,
        random: Random(1),
      );
      expect(r.length, 1);
      expect(['a', 'b'], contains(r.first.food.id));
    });

    test('returns empty when nothing is eligible', () {
      expect(
        engine.recommend(
          [food('a', price: 999)],
          craving: Craving.surprise,
          budget: Budget.under300,
        ),
        isEmpty,
      );
    });
  });
}
