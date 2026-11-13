// lib/screens/terms_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';


const _textDark = Color(0xFF2A1F1A);
const _textSoft = Color(0xFF6B5A50);

/// Keep this in ONE place and reuse it on the Register screen too, so what
/// the user ticks at sign-up is exactly what they can read here later.
const kTermsVersion = '1.0';

const kTermsSections = <({String title, String body})>[
  (
  title: '1. About Ghar Ka Khana',
  body:
  'Ghar Ka Khana is a marketplace that connects customers with independent home cooks. We are not the cook and do not prepare the food; we provide the platform for ordering.'
  ),
  (
  title: '2. Your account',
  body:
  'You must provide accurate name, phone number and delivery address. You are responsible for keeping your login details secure and for all activity under your account.'
  ),
  (
  title: '3. Orders and pricing',
  body:
  'Prices and availability are set by each cook. An order is confirmed once the cook accepts it. Delivery charges, if any, are shown before you place the order.'
  ),
  (
  title: '4. Payments',
  body:
  'You can pay by Cash on Delivery or through the available online payment option. For online payments, your payment details are handled by the payment provider and are not stored by us.'
  ),
  (
  title: '5. Cancellations and refunds',
  body:
  'You may cancel an order before the cook starts preparing it. Once preparation has started, cancellation may not be possible. Refunds for online payments are processed back to the original payment method.'
  ),
  (
  title: '6. Food and allergens',
  body:
  'Food is prepared in home kitchens by independent cooks. Please read item descriptions and contact the cook about allergies. We cannot guarantee that any item is free of allergens.'
  ),
  (
  title: '7. Acceptable use',
  body:
  'Do not misuse the app, place fake orders, abuse cooks or delivery staff, or post false reviews. We may suspend accounts that break these rules.'
  ),
  (
  title: '8. Liability',
  body:
  'To the extent permitted by law, Ghar Ka Khana is not liable for the quality of food prepared by cooks or for delays outside our control. Please report any problem through Help & Support.'
  ),
  (
  title: '9. Changes to these terms',
  body:
  'We may update these terms from time to time. Continued use of the app after an update means you accept the new terms.'
  ),
];

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text('Terms & Conditions',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600, color: _textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Acceptance banner: reads termsAcceptedAt saved at registration.
          if (uid != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data() ?? {};
                final ts = data['termsAcceptedAt'];
                final ver = data['termsVersion'] ?? kTermsVersion;
                if (ts is! Timestamp) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You accepted these terms (v$ver) on ${_fmt(ts.toDate())}.',
                          style: GoogleFonts.outfit(
                              fontSize: 15, color: _textDark),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in kTermsSections) ...[
                  Text(s.title,
                      style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _textDark)),
                  const SizedBox(height: 6),
                  Text(s.body,
                      style: GoogleFonts.outfit(
                          fontSize: 15, height: 1.5, color: _textSoft)),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}