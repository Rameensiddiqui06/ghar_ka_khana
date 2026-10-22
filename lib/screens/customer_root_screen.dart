// import 'package:flutter/material.dart';
// import '../core/app_colors.dart';
// import '../services/auth_service.dart';
// import '../services/seed_data.dart';
// import 'auth_gate.dart';
// import 'customer/home_screen.dart';
// import 'customer/explore_screen.dart';

// class CustomerRootScreen extends StatefulWidget {
//   const CustomerRootScreen({super.key});

//   @override
//   State<CustomerRootScreen> createState() => _CustomerRootScreenState();
// }

// class _CustomerRootScreenState extends State<CustomerRootScreen> {
//   int _tabIndex = 0;
//   final Set<String> _favorites = {};

//   void _onNav(String screen, {Map<String, dynamic>? params}) {
//     if (screen == 'explore') {
//       setState(() => _tabIndex = 1);
//       return;
//     }
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('This screen is coming in a later phase.')),
//     );
//   }

//   void _toggleFav(String id) {
//     setState(() {
//       if (_favorites.contains(id)) {
//         _favorites.remove(id);
//       } else {
//         _favorites.add(id);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tabs = [
//       HomeScreen(onNav: _onNav, favorites: _favorites, onFav: _toggleFav),
//       ExploreScreen(onNav: _onNav, favorites: _favorites, onFav: _toggleFav),
//       const Center(child: Text('Orders — coming in a later phase', style: TextStyle(color: AppColors.muted))),
//       const Center(child: Text('Favorites — coming in a later phase', style: TextStyle(color: AppColors.muted))),
//       Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Profile — coming in a later phase', style: TextStyle(color: AppColors.muted)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 await seedSampleData();
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Sample data added!')),
//                   );
//                 }
//               },
//               child: const Text('Seed Sample Data (temporary)'),
//             ),
//             const SizedBox(height: 12),
//             OutlinedButton(
//               onPressed: () async {
//                 await AuthService().signOut();
//                 if (context.mounted) {
//                   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthGate()), (route) => false);
//                 }
//               },
//               child: const Text('Sign Out'),
//             ),
//           ],
//         ),
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(child: tabs[_tabIndex]),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _tabIndex,
//         onTap: (i) => setState(() => _tabIndex = i),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: AppColors.muted,
//         selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//         unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
//         items: const [
//           BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 18)), label: 'Home'),
//           BottomNavigationBarItem(icon: Text('🔍', style: TextStyle(fontSize: 18)), label: 'Explore'),
//           BottomNavigationBarItem(icon: Text('📦', style: TextStyle(fontSize: 18)), label: 'Orders'),
//           BottomNavigationBarItem(icon: Text('♡', style: TextStyle(fontSize: 18)), label: 'Saved'),
//           BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 18)), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import '../services/seed_data.dart';
import 'auth_gate.dart';
import 'customer/home_screen.dart';
import 'customer/explore_screen.dart';

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
    if (screen == 'explore') {
      setState(() {
        _tabIndex = 1;
        _exploreCategory = params?['category'] as String?;
      });
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
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profile — coming in a later phase', style: TextStyle(color: AppColors.muted)),
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
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthGate()), (route) => false);
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