import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/food.dart';
import '../../services/food_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/food_card_h.dart';

class SavedScreen extends StatefulWidget {
  final Set<String> favorites;
  final void Function(String id) onFav;
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;

  const SavedScreen({
    super.key,
    required this.favorites,
    required this.onFav,
    required this.onNav,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _service = FoodService();
  List<Food> _foods = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final foods = await _service.getFoods();
      if (!mounted) return;
      setState(() {
        _foods = foods;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Error loading saved foods: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load saved dishes.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: AppColors.muted)),
      );
    }

    // Filter from the live favorites set, so un-saving removes the card instantly.
    final saved = _foods.where((f) => widget.favorites.contains(f.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Text(
                'Saved',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${saved.length} dish${saved.length == 1 ? '' : 'es'}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: saved.isEmpty
              ? const EmptyState(
                  emoji: '♡',
                  title: 'Nothing saved yet',
                  subtitle: 'Tap the heart on a dish to save it here',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: saved.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final f = saved[i];
                    return FoodCardH(
                      food: f,
                      isFav: true,
                      onFav: () => widget.onFav(f.id),
                      onPress: () =>
                          widget.onNav('product', params: {'foodId': f.id}),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
