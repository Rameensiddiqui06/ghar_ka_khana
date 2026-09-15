import 'package:flutter/material.dart';
import '../models/role.dart';
import '../screens/customer_home_screen.dart';
import '../screens/seller_home_screen.dart';
import '../screens/admin_home_screen.dart';

Widget homeScreenForRole(Role role) {
  switch (role) {
    case Role.customer:
      return const CustomerHomeScreen();
    case Role.seller:
      return const SellerHomeScreen();
    case Role.admin:
      return const AdminHomeScreen();
  }
}