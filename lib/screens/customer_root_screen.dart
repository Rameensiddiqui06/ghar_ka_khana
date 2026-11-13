import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'customer/home_screen.dart';
import 'customer/explore_screen.dart';
import 'customer/cust_profile.dart';


class CustomerRootScreen extends StatefulWidget {
  const CustomerRootScreen({super.key});

  @override
  State<CustomerRootScreen> createState() => _CustomerRootScreenState();
}

class _CustomerRootScreenState extends State<CustomerRootScreen> {
  int _tabIndex = 0;
  final Set<String> _favorites = {};
  String? _exploreCategory;

  void _onNav(String screen, {Map<String, dynamic>? params}) {
    switch (screen) {
      case 'explore':
        setState(() {
          _tabIndex = 1;
          _exploreCategory = params?['category'] as String?;
        });
        return;
      case 'orders':
        setState(() => _tabIndex = 2);
        return;
      case 'saved':
        setState(() => _tabIndex = 3);
        return;
      case 'profile':
        setState(() => _tabIndex = 4);
        return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This screen is coming in a later phase.')),
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

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(onNav: _onNav, favorites: _favorites, onFav: _toggleFav),
      ExploreScreen(key: ValueKey(_exploreCategory), onNav: _onNav, favorites: _favorites, onFav: _toggleFav, initialCategory: _exploreCategory),
      const Center(child: Text('Orders — coming in a later phase', style: TextStyle(color: AppColors.muted))),
      const Center(child: Text('Favorites — coming in a later phase', style: TextStyle(color: AppColors.muted))),
      CustProfileScreen(onNav: _onNav),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: tabs[_tabIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 18)), label: 'Home'),
          BottomNavigationBarItem(icon: Text('🔍', style: TextStyle(fontSize: 18)), label: 'Explore'),
          BottomNavigationBarItem(icon: Text('📦', style: TextStyle(fontSize: 18)), label: 'Orders'),
          BottomNavigationBarItem(icon: Text('♡', style: TextStyle(fontSize: 18)), label: 'Saved'),
          BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 18)), label: 'Profile'),
        ],
      ),
    );
  }
}
