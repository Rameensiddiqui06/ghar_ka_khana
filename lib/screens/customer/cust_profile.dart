// lib/screens/customer/cust_profile.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth_gate.dart';
import 'cust_edit_profile.dart';
import '../terms_screen.dart';
import 'privacy_screen.dart';
import 'help_screen.dart';
import '../../services/cart_controller.dart';

const _textDark = Color(0xFF2A1F1A);
const _textSoft = Color(0xFF6B5A50);
const _divider = Color(0xFFF0E6DC);
const _danger = Color(0xFFD94545);

class CustProfileScreen extends StatelessWidget {
  final void Function(String screen, {Map<String, dynamic>? params}) onNav;

  const CustProfileScreen({super.key, required this.onNav});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('You will need to sign in again to place orders.',
            style: GoogleFonts.outfit(color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout',
                style: GoogleFonts.outfit(
                    color: _danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (ok != true) return;
    CartController.instance.clear();
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final pwController = TextEditingController();
    String? error;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete account?',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This permanently deletes your profile, address and photo. '
                    'This cannot be undone. Enter your password to confirm.',
                style: GoogleFonts.outfit(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwController,
                obscureText: true,
                decoration:
                InputDecoration(labelText: 'Password', errorText: error),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: GoogleFonts.outfit(color: AppColors.muted)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Firebase requires a recent login before deleting.
                  final cred = EmailAuthProvider.credential(
                      email: user.email ?? '', password: pwController.text);
                  await user.reauthenticateWithCredential(cred);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .delete();
                  await user.delete();
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } on FirebaseAuthException {
                  setState(() => error = 'Wrong password or please log in again.');
                } catch (_) {
                  setState(() => error = 'Something went wrong. Try again.');
                }
              },
              child: Text('Delete',
                  style: GoogleFonts.outfit(
                      color: _danger, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
    pwController.dispose();

    if (ok == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    }
  }

  /// Reads the first non-empty string among several possible field names.
  String _str(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Center(child: Text('Not signed in.'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        final email = _str(data, ['email']).isNotEmpty
            ? _str(data, ['email'])
            : (user.email ?? '');
        var name = _str(data, ['name', 'fullName']);
        if (name.isEmpty && email.isNotEmpty) name = email.split('@').first;
        final phone = _str(data, ['phone', 'phoneNumber', 'mobile']);
        final address = _str(data, ['address']);
        final photoBase64 = _str(data, ['photoBase64']);
        final photoUrl = _str(data, ['photoUrl']);

        void openEdit() {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EditProfileScreen(
              uid: user.uid,
              name: name,
              email: email,
              phone: phone,
              address: address,
              photoBase64: photoBase64.isEmpty ? null : photoBase64,
            ),
          ));
        }

        void openTerms() {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TermsScreen(),
          ));
        }

        void openPrivacy() {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const PrivacyScreen(),
          ));
        }

        void openHelp() {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const HelpScreen(),
          ));
        }

        final items = <_MenuItem>[
          _MenuItem('📦', 'My Orders', 'Track and view orders', 'orders'),
          _MenuItem('🤍', 'Favorites', 'Saved foods and cooks', 'saved'),
          _MenuItem('🔔', 'Notifications', 'Order updates and offers',
              'notifications'),
          _MenuItem('❓', 'Help & Support', 'FAQs and contact', 'help'),
          _MenuItem('📄', 'Terms & Conditions', 'What you agreed to at sign-up',
              'terms'),
          _MenuItem('🔒', 'Privacy Policy', 'How we use your data', 'privacy'),
        ];

        return SingleChildScrollView(
          child: Column(
            children: [
              _Header(
                name: name,
                address: address,
                phone: phone,
                photoBase64: photoBase64,
                photoUrl: photoUrl,
                onEdit: openEdit,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            _MenuTile(
                              item: items[i],
                              onTap: () {
                                switch (items[i].target) {
                                  case 'terms':
                                    openTerms();
                                    break;
                                  case 'privacy':
                                    openPrivacy();
                                    break;
                                  case 'help':
                                    openHelp();
                                    break;
                                  default:
                                    onNav(items[i].target);
                                }
                              },
                            ),
                            if (i != items.length - 1)
                              const Divider(height: 1, color: _divider),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _confirmLogout(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _danger, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: Text('Logout',
                            style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: _danger)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _confirmDeleteAccount(context),
                      child: Text('Delete Account',
                          style: GoogleFonts.outfit(
                              fontSize: 15, color: AppColors.muted)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- Header ----------
class _Header extends StatelessWidget {
  final String name, address, phone, photoBase64, photoUrl;
  final VoidCallback onEdit;

  const _Header({
    required this.name,
    required this.address,
    required this.phone,
    required this.photoBase64,
    required this.photoUrl,
    required this.onEdit,
  });

  Widget _avatarContent() {
    if (photoBase64.isNotEmpty) {
      return Image.memory(base64Decode(photoBase64),
          fit: BoxFit.cover, gaplessPlayback: true);
    }
    if (photoUrl.isNotEmpty) {
      return Image.network(photoUrl, fit: BoxFit.cover);
    }
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.playfairDisplay(
            fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary, width: 2),
                  color: const Color(0xFFE8B4B0),
                ),
                clipBehavior: Clip.antiAlias,
                child: _avatarContent(),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: _textDark)),
                    const SizedBox(height: 4),
                    Text(address.isEmpty ? 'Add delivery address' : address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: address.isEmpty
                                ? AppColors.muted
                                : _textSoft)),
                    const SizedBox(height: 2),
                    Text(phone.isEmpty ? 'Add phone number' : phone,
                        style: GoogleFonts.outfit(
                            fontSize: 16, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Edit Profile',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ---------- Menu list ----------
class _MenuItem {
  final String emoji;
  final String title;
  final String? subtitle;
  final String target;
  _MenuItem(this.emoji, this.title, this.subtitle, this.target);
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;
  const _MenuTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(item.emoji,
                  style: const TextStyle(fontSize: 26),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: _textDark)),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            fontSize: 14.5, color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}