import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'name': name ?? '',
      'role': role.name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return role;
  }

  /// Signs in an existing user and fetches their role from Firestore.
  Future<Role> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data()?['role'] == null) {
      throw Exception('No role found for this account.');
    }

    return RoleX.fromString(doc.data()!['role'] as String);
  }

  /// Used by AuthGate to check the role of an already-logged-in user.
  Future<Role?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data()?['role'] == null) return null;

    return RoleX.fromString(doc.data()!['role'] as String);
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}