import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = <(String, String)>[
    (
    'Information we collect',
    'When you create an account we collect your name, email address, '
        'phone number, delivery address and an optional profile photo. '
        'We also store your order history and a device token so we can '
        'send you order updates.'
    ),
    (
    'How we use your information',
    'We use your information to create and manage your account, process '
        'and deliver your orders, share the details cooks need to prepare '
        'and deliver your food, and send notifications about your orders '
        'and offers.'
    ),
    (
    'Who can see your data',
    'Your name, phone number and delivery address are shared with the '
        'cook and delivery person handling your order. We do not sell '
        'your personal information to third parties.'
    ),
    (
    'Data storage and security',
    'Your data is stored using Google Firebase services. Passwords are '
        'handled by Firebase Authentication and are never visible to us.'
    ),
    (
    'Notifications',
    'You may receive push notifications about order status and offers. '
        'You can turn these off at any time in your device settings.'
    ),
    (
    'Your rights',
    'You can edit your profile details at any time from Edit Profile. '
        'You can also permanently delete your account and profile data '
        'from the Profile screen using Delete Account.'
    ),
    (
    'Contact us',
    'If you have questions about this policy, contact us through '
        'Help & Support in the app.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2A1F1A)),
        title: Text('Privacy Policy',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600, color: const Color(0xFF2A1F1A))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Last updated: November 2026',
              style: GoogleFonts.outfit(color: AppColors.muted)),
          const SizedBox(height: 16),
          for (final s in _sections) ...[
            Text(s.$1,
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A1F1A))),
            const SizedBox(height: 6),
            Text(s.$2,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    height: 1.5,
                    color: const Color(0xFF6B5A50))),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}