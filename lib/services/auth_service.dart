

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/role.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Registers a new user, then writes their role to Firestore.
//   Future<Role> register({
//     required String email,
//     required String password,
//     required Role role,
//     String? name,
//   }) async {
//     final credential = await _auth.createUserWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     final uid = credential.user!.uid;

//     await _firestore.collection('users').doc(uid).set({
//       'uid': uid,
//       'email': email.trim(),
//       'name': name ?? '',
//       'role': role.name,
//       'kitchenName': role == Role.seller ? "${name ?? 'My'} Kitchen" : '',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     return role;
//   }

//   /// Signs in an existing user and fetches their role from Firestore.
//   Future<Role> login({required String email, required String password}) async {
//     final credential = await _auth.signInWithEmailAndPassword(
//       email: email.trim(),
//       password: password,
//     );

//     final uid = credential.user!.uid;
//     final doc = await _firestore.collection('users').doc(uid).get();

//     if (!doc.exists || doc.data()?['role'] == null) {
//       throw Exception('No role found for this account.');
//     }

//     return RoleX.fromString(doc.data()!['role'] as String);
//   }

//   /// Sends a password reset email.
//   Future<void> resetPassword({required String email}) async {
//     await _auth.sendPasswordResetEmail(email: email.trim());
//   }

//   /// Used by AuthGate to check the role of an already-logged-in user.
//   Future<Role?> getCurrentUserRole() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;

//     final doc = await _firestore.collection('users').doc(user.uid).get();

//     // If doc isn't ready immediately upon quick registration, retry briefly
//     if (!doc.exists || doc.data()?['role'] == null) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       final retryDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (!retryDoc.exists || retryDoc.data()?['role'] == null) return null;
//       return RoleX.fromString(retryDoc.data()!['role'] as String);
//     }

//     return RoleX.fromString(doc.data()!['role'] as String);
//   }

//   User? get currentUser => _auth.currentUser;

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registers a new user, then writes their role to Firestore.
  Future<Role> register({
    required String email,
    required String password,
    required Role role,
    String? name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final kitchenName = role == Role.seller ? "${name ?? 'My'} Kitchen" : '';

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'name': name ?? '',
      'role': role.name,
      'kitchenName': kitchenName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (role == Role.seller) {
      await _ensureSellerDocs(uid, name ?? '', kitchenName);
    }

    return role;
  }

  /// Signs in an existing user and fetches their role from Firestore.
  Future<Role> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data()?['role'] == null) {
      throw Exception('No role found for this account.');
    }

    final data = doc.data()!;
    final role = RoleX.fromString(data['role'] as String);

    if (role == Role.seller) {
      final name = (data['name'] ?? '') as String;
      final kn = (data['kitchenName'] ?? '') as String;
      await _ensureSellerDocs(uid, name, kn.isNotEmpty ? kn : "$name Kitchen");
    }

    return role;
  }

  /// Makes sure kitchens/{uid} and sellers/{uid} exist for a seller, so the
  /// customer app can show the kitchen name and payment details at checkout.
  /// Never throws: a failure here must not block login.
  Future<void> _ensureSellerDocs(
    String uid,
    String name,
    String kitchenName,
  ) async {
    try {
      final kitchenRef = _firestore.collection('kitchens').doc(uid);
      final sellerRef = _firestore.collection('sellers').doc(uid);
      final results = await Future.wait([kitchenRef.get(), sellerRef.get()]);

      final displayName = kitchenName.isNotEmpty ? kitchenName : 'Home Kitchen';

      if (!results[0].exists) {
        await kitchenRef.set({
          'ownerId': uid,
          'kitchenName': displayName,
          'name': name,
          'isOpen': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!results[1].exists) {
        await sellerRef.set({
          'name': displayName,
          'avatarUrl': '',
          'coverUrl': '',
          'avatarEmoji': '👩‍🍳',
          'avatarBgHex': '#C2513A',
          'coverEmoji': '🍲',
          'coverBgHex': '#8B3A2C',
          'rating': 0,
          'reviews': 0,
          'location': 'Karachi',
          'distance': '',
          'cuisines': <String>[],
          'verified': true,
          'topRated': false,
          'description': '',
          'story': '',
          'hours': '',
          'days': '',
          'easypaisaNumber': '',
          'jazzcashNumber': '',
          'accountTitle': '',
        });
      }
    } catch (e) {
      debugPrint('Could not create seller docs: $e');
    }
  }

  /// Sends a password reset email.
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Used by AuthGate to check the role of an already-logged-in user.
  Future<Role?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data()?['role'] == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      final retryDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!retryDoc.exists || retryDoc.data()?['role'] == null) return null;
      return RoleX.fromString(retryDoc.data()!['role'] as String);
    }

    return RoleX.fromString(doc.data()!['role'] as String);
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}