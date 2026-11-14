import 'package:firebase_auth/firebase_auth.dart';

/// Re-authenticates with the current password, then sets the new one.
/// Returns null on success, or a message to show the user.
Future<String?> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.email == null) {
    return 'You are not signed in with an email account.';
  }
  try {
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
    return null;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect.';
      case 'weak-password':
        return 'New password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Could not change password. Try again.';
    }
  } catch (_) {
    return 'Something went wrong. Try again.';
  }
}