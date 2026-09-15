import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/role_home.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (authService.currentUser == null) {
      return const WelcomeScreen();
    }

    return FutureBuilder(
      future: authService.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return homeScreenForRole(snapshot.data!);
        }

        // Logged in but no role found — treat as logged out.
        return const WelcomeScreen();
      },
    );
  }
}