
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import '../services/cart_controller.dart';
import '../services/seed_data.dart';
import 'auth_gate.dart';
import 'customer/cart_screen.dart';
import 'customer/explore_screen.dart';
import 'customer/food_detail_screen.dart';
import 'customer/home_screen.dart';
import 'customer/khana_buddy_screen.dart'; // ADDED: Khana Buddy import
import 'customer/orders_screen.dart';
import 'customer/saved_screen.dart';
import 'customer/seller_detail_screen.dart';

class CustomerRootScreen extends StatefulWidget {
  const CustomerRootScreen({super.key});

  @override
  State<CustomerRootScreen> createState() => _CustomerRootScreenState();
}

class _CustomerRootScreenState extends State<CustomerRootScreen> {
  int _tabIndex = 0;
  final Set<String> _favorites = {};
  final CartController _cart = CartController();
  String? _exploreCategory;

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  void _onNav(String screen, {Map<String, dynamic>? params}) {
    if (screen == 'khanaBuddy') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => KhanaBuddyScreen(
            onBack: () => Navigator.of(ctx).pop(),
            favorites: _favorites,
            onFav: _toggleFav,
            onNav: _onNav,
          ),
        ),
      );
      return;
    }

    if (screen == 'explore') {
      setState(() {
        _tabIndex = 1;
        _exploreCategory = params?['category'] as String?;
      });
      return;
    }
    if (screen == 'seller') {
      final sellerId = params?['sellerId'] as String?;
      if (sellerId == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => SellerDetailScreen(
            sellerId: sellerId,
            onBack: () => Navigator.of(ctx).pop(),
            favorites: _favorites,
            onFav: _toggleFav,
            onNav: _onNav,
          ),
        ),
      );
      return;
    }
    if (screen == 'product') {
      final foodId = params?['foodId'] as String?;
      if (foodId == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => FoodDetailScreen(
            foodId: foodId,
            onBack: () => Navigator.of(ctx).pop(),
            favorites: _favorites,
            onFav: _toggleFav,
            onNav: _onNav,
            cart: _cart,
          ),
        ),
      );
      return;
    }
    if (screen == 'cart') {
      _openCart();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This screen is coming in a later phase.')),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) =>
            CartScreen(cart: _cart, onBack: () => Navigator.of(ctx).pop()),
      ),
    );
  }

  void _toggleFav(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  Widget _cartButton() {
    final n = _cart.itemCount;
    return GestureDetector(
      onTap: _openCart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$n item${n == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(onNav: _onNav, favorites: _favorites, onFav: _toggleFav),
      ExploreScreen(
        key: ValueKey(_exploreCategory),
        onNav: _onNav,
        favorites: _favorites,
        onFav: _toggleFav,
        initialCategory: _exploreCategory,
      ),
      const OrdersScreen(),
      SavedScreen(favorites: _favorites, onFav: _toggleFav, onNav: _onNav),
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile — coming in a later phase',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await seedSampleData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sample data added!')),
                  );
                }
              },
              child: const Text('Seed Sample Data (temporary)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(child: tabs[_tabIndex]),
          // Floating cart button on Home, Explore and Orders
          if (_tabIndex <= 2)
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedBuilder(
                animation: _cart,
                builder: (context, _) =>
                    _cart.isEmpty ? const SizedBox.shrink() : _cartButton(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Text('🏠', style: TextStyle(fontSize: 18)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text('🔍', style: TextStyle(fontSize: 18)),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Text('📦', style: TextStyle(fontSize: 18)),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Text('♡', style: TextStyle(fontSize: 18)),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Text('👤', style: TextStyle(fontSize: 18)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
