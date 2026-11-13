// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/auth_service.dart';
// import '../core/role_home.dart';
// import 'welcome_screen.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = AuthService();

//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, authSnapshot) {
//         if (authSnapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = authSnapshot.data;

//         if (user == null) {
//           return const WelcomeScreen();
//         }

//         return FutureBuilder(
//           key: ValueKey(user.uid),
//           future: authService.getCurrentUserRole(),
//           builder: (context, roleSnapshot) {
//             if (roleSnapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             if (roleSnapshot.hasData && roleSnapshot.data != null) {
//               return homeScreenForRole(roleSnapshot.data!);
//             }

//             return const WelcomeScreen();
//           },
//         );
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../core/role_home.dart';
import 'welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  // Created once, so rebuilds never re-subscribe.
  late final Stream<User?> _authStream =
      FirebaseAuth.instance.authStateChanges();

  // Role lookup is cached per user, so rebuilds never restart it
  // (a restart would flash a spinner and destroy the home screen).
  String? _cachedUid;
  Future<dynamic>? _roleFuture;

  Future<dynamic> _roleFor(String uid) {
    if (_cachedUid != uid || _roleFuture == null) {
      _cachedUid = uid;
      _roleFuture = _authService.getCurrentUserRole();
    }
    return _roleFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          _cachedUid = null;
          _roleFuture = null;
          return const WelcomeScreen();
        }

        return FutureBuilder<dynamic>(
          key: ValueKey(user.uid),
          future: _roleFor(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasData && roleSnapshot.data != null) {
              return homeScreenForRole(roleSnapshot.data!);
            }

            // No role found yet: forget the cache so the next rebuild retries.
            _roleFuture = null;
            return const WelcomeScreen();
          },
        );
      },
    );
  }
}