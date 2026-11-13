// lib/screens/customer/edit_profile_screen.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';

const _textDark = Color(0xFF2A1F1A);
const _divider = Color(0xFFF0E6DC);
const _danger = Color(0xFFD94545);

class EditProfileScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? photoBase64;

  const EditProfileScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.photoBase64,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  String? _photoBase64;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _phoneCtrl = TextEditingController(text: widget.phone);
    _addressCtrl = TextEditingController(text: widget.address);
    _photoBase64 = widget.photoBase64;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 60,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    } catch (e) {
      _snack('Could not get the photo: $e');
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primary),
              title: Text('Take a photo', style: GoogleFonts.outfit()),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text('Choose from gallery', style: GoogleFonts.outfit()),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: _danger),
                title: Text('Remove photo',
                    style: GoogleFonts.outfit(color: _danger)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoBase64 = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      _snack('Name cannot be empty.');
      return;
    }
    if (phone.isNotEmpty &&
        phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      _snack('Please enter a valid phone number.');
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'name': name,
        'phone': phone,
        'address': _addressCtrl.text.trim(),
        'photoBase64': _photoBase64 ?? FieldValue.delete(),
      }, SetOptions(merge: true));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Could not save: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: Text('Edit Profile',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---- Avatar ----
            GestureDetector(
              onTap: _showPhotoOptions,
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.primary, width: 2),
                      color: const Color(0xFFE8B4B0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _photoBase64 != null
                        ? Image.memory(base64Decode(_photoBase64!),
                        fit: BoxFit.cover, gaplessPlayback: true)
                        : Center(
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showPhotoOptions,
              child: Text('Change photo',
                  style: GoogleFonts.outfit(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),

            // ---- Fields ----
            _field(_nameCtrl, 'Full name', TextInputType.name,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            _field(_phoneCtrl, 'Phone number', TextInputType.phone),
            const SizedBox(height: 14),
            _field(TextEditingController(text: widget.email), 'Email',
                TextInputType.emailAddress,
                enabled: false,
                helper: 'Email is your login and can\'t be changed here.'),
            const SizedBox(height: 14),
            _field(_addressCtrl, 'Delivery address', TextInputType.streetAddress,
                maxLines: 3,
                helper: 'House no., street, area, city'),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text('Save Changes',
                    style: GoogleFonts.outfit(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController c,
      String label,
      TextInputType type, {
        int maxLines = 1,
        bool enabled = true,
        String? helper,
        ValueChanged<String>? onChanged,
      }) {
    return TextField(
      controller: c,
      keyboardType: type,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      style: GoogleFonts.outfit(color: enabled ? _textDark : AppColors.muted),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF3EEE8),
        labelStyle: GoogleFonts.outfit(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _divider),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}