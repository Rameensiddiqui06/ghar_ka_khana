import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/khana_buddy_ai_recommender.dart';
import '../../services/khana_buddy_engine.dart';
import '../../services/khana_buddy_service.dart';
import '../../widgets/food_card_h.dart';
import '../../widgets/primary_button.dart';

enum _Status { idle, loading, error, done }

class KhanaBuddyScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Set<String> favorites;
  final void Function(String id) onFav;
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;
  final KhanaBuddyRecommender? recommender;

  const KhanaBuddyScreen({
    super.key,
    required this.onBack,
    required this.favorites,
    required this.onFav,
    required this.onNav,
    this.recommender,
  });

  @override
  State<KhanaBuddyScreen> createState() => _KhanaBuddyScreenState();
}

class _KhanaBuddyScreenState extends State<KhanaBuddyScreen> {
  late final KhanaBuddyRecommender _recommender;
  Craving? _craving;
  Budget? _budget;
  _Status _status = _Status.idle;
  List<KhanaBuddyRecommendation> _results = [];

  @override
  void initState() {
    super.initState();
    _recommender = widget.recommender ??
        AiKhanaBuddyRecommender(fallback: RuleBasedKhanaBuddyRecommender());
  }

  Future<void> _find() async {
    final craving = _craving;
    final budget = _budget;
    if (craving == null || budget == null) return;
    setState(() => _status = _Status.loading);
    try {
      final r = await _recommender.recommend(craving: craving, budget: budget);
      if (!mounted) return;
      setState(() {
        _results = r;
        _status = _Status.done;
      });
    } catch (e) {
      debugPrint('Khana Buddy error: $e');
      if (!mounted) return;
      setState(() => _status = _Status.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _craving != null && _budget != null;
    final loading = _status == _Status.loading;
    final again = _status == _Status.done && _craving == Craving.surprise;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Khana Buddy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us your craving and budget. We\'ll suggest dishes that '
              'are available right now.',
              style: TextStyle(fontSize: 13, color: AppColors.text2),
            ),
            const SizedBox(height: 20),
            const Text(
              'What are you craving?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _cravingCard(Craving.spicy)),
                const SizedBox(width: 10),
                Expanded(child: _cravingCard(Craving.comfort)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _cravingCard(Craving.light)),
                const SizedBox(width: 10),
                Expanded(child: _cravingCard(Craving.surprise)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Your budget',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Includes delivery fee',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Budget.values.map(_budgetPill).toList(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: loading
                  ? 'Finding...'
                  : (again ? 'Surprise me again' : 'Find My Food'),
              disabled: !ready || loading,
              onPressed: _find,
            ),
            const SizedBox(height: 20),
            _resultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _cravingCard(Craving c) {
    final selected = _craving == c;
    return GestureDetector(
      onTap: () => setState(() => _craving = c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.sand,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(c.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetPill(Budget b) {
    final selected = _budget == b;
    return GestureDetector(
      onTap: () => setState(() => _budget = b),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.sand,
            width: 1.5,
          ),
        ),
        child: Text(
          b.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }

  Widget _resultsSection() {
    switch (_status) {
      case _Status.idle:
        return const SizedBox.shrink();
      case _Status.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      case _Status.error:
        return Column(
          children: [
            const Text(
              'Could not load dishes. Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            PrimaryButton(text: 'Try again', onPressed: _find),
          ],
        );
      case _Status.done:
        if (_results.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _craving == Craving.surprise
                  ? 'No available dishes fit ${_budget?.label.toLowerCase()} '
                      'including delivery. Try a higher budget.'
                  : 'No available dishes matched "${_craving?.label}" '
                      '${_budget?.label.toLowerCase()} including delivery. '
                      'Try a higher budget or a different craving.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                height: 1.4,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suggestions for you',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Totals are for one portion from one seller. Ordering from '
              'more sellers adds a delivery fee for each.',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            ..._results.map(_resultTile),
          ],
        );
    }
  }

  Widget _resultTile(KhanaBuddyRecommendation r) {
    final f = r.food;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          FoodCardH(
            food: f,
            isFav: widget.favorites.contains(f.id),
            onFav: () {
              widget.onFav(f.id);
              setState(() {});
            },
            onPress: () => widget.onNav('product', params: {'foodId': f.id}),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...r.reasons.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '✓ $t',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text2,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Rs. ${r.foodSubtotal} food + Rs. ${r.deliveryFee} '
                  'delivery = Rs. ${r.total}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}