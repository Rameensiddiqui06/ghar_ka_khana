import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const supportEmail = 'eshaalfaisal35@gmail.com'; // TODO: your email

const _textDark = Color(0xFF2A1F1A);
const _textSoft = Color(0xFF6B5A50);

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const _topics = [
    'Order issue',
    'Payment',
    'Delivery',
    'Account',
    'Other',
  ];

  static const _faqs = <(String, String)>[
    ('How do I track my order?',
    'Open the Orders tab to see the live status of your current order.'),
    ('How do I cancel an order?',
    'You can cancel before the cook starts preparing it. After that, '
        'please contact us using the form below.'),
    ('How do I change my delivery address?',
    'Go to Profile > Edit Profile and update your address. It will be '
        'used for your next order.'),
    ('What payment methods are available?',
    'Currently Cash on Delivery. Pay the delivery person when your '
        'food arrives.'),
    ('My food arrived late or incorrect. What now?',
    'Send us a message below with your order details and we will '
        'look into it.'),
    ('How do I delete my account?',
    'Go to Profile and tap Delete Account at the bottom. This '
        'permanently removes your data.'),
  ];

  final _messageCtrl = TextEditingController();
  String _topic = _topics.first;
  bool _sending = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _emailUs() async {
    final user = FirebaseAuth.instance.currentUser;
    final subject = Uri.encodeComponent('Ghar Ka Khana support');
    final body = Uri.encodeComponent(
        'Account email: ${user?.email ?? ''}\n'
            'User ID: ${user?.uid ?? ''}\n\n'
            'Describe your problem here:\n\n\n');

    final gmail = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$supportEmail&su=$subject&body=$body');
    final mailto = Uri.parse('mailto:$supportEmail?subject=$subject&body=$body');

    try {
      if (kIsWeb) {
        await launchUrl(gmail, webOnlyWindowName: '_blank');
        return;
      }
      if (await launchUrl(mailto)) return;
      if (await launchUrl(gmail, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}

    await Clipboard.setData(const ClipboardData(text: supportEmail));
    _snack('Email address copied: $supportEmail');
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _messageCtrl.text.trim();
    if (user == null) return;
    if (text.length < 10) {
      _snack('Please describe your problem in a bit more detail.');
      return;
    }
    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'uid': user.uid,
        'email': user.email,
        'topic': _topic,
        'message': text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _messageCtrl.clear();
      _snack('Message sent. We will get back to you.');
    } catch (e) {
      debugPrint('Ticket error: $e');
      _snack('Could not send: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: Text('Help & Support',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600, color: _textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _sectionTitle('Frequently asked questions'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final f in _faqs)
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      title: Text(f.$1,
                          style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: _textDark)),
                      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      expandedAlignment: Alignment.centerLeft,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(f.$2,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.outfit(
                                  fontSize: 15.5, height: 1.5, color: _textSoft)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Contact us'),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _emailUs,
              icon: const Icon(Icons.email_outlined,
                  color: AppColors.primary),
              label: Text('Email us',
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(supportEmail,
                style: GoogleFonts.outfit(color: AppColors.muted)),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Send us a message'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _topic,
                  decoration: const InputDecoration(labelText: 'Topic'),
                  items: [
                    for (final t in _topics)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (v) => setState(() => _topic = v ?? _topic),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageCtrl,
                  maxLines: 5,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Describe your problem',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _sending
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : Text('Send',
                        style: GoogleFonts.outfit(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          if (uid != null) ...[
            const SizedBox(height: 24),
            _sectionTitle('Your requests'),
            _MyTickets(uid: uid),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(t,
        style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w600, color: _textDark)),
  );
}

class _MyTickets extends StatelessWidget {
  final String uid;
  const _MyTickets({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // No orderBy here, so no Firestore index is needed; we sort below.
      stream: FirebaseFirestore.instance
          .collection('support_tickets')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final docs = snap.data!.docs.toList()
          ..sort((a, b) {
            final ta = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 1 << 50;
            final tb = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 1 << 50;
            return tb.compareTo(ta);
          });
        if (docs.isEmpty) {
          return Text('No requests yet.',
              style: GoogleFonts.outfit(color: AppColors.muted));
        }
        return Column(
          children: [
            for (final d in docs)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(d.data()['topic'] ?? '',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: _textDark)),
                        ),
                        _StatusChip(status: d.data()['status'] ?? 'pending'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(d.data()['message'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(color: _textSoft)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final resolved = status == 'resolved';
    final color = resolved ? const Color(0xFF2E9E5B) : const Color(0xFFE08A00);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(resolved ? 'Resolved' : 'Pending',
          style: GoogleFonts.outfit(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}