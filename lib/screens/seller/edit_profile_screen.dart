import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/change_password.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({Key? key, required this.currentData})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _accent = Color(0xFFD95325);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _cuisineController;
  late TextEditingController _locationController;
  late TextEditingController _hoursController;
  late TextEditingController _easypaisaController;
  late TextEditingController _jazzcashController;
  late TextEditingController _accountTitleController;

  // Change password (inline section)
  final _curPw = TextEditingController();
  final _newPw = TextEditingController();
  final _confPw = TextEditingController();
  bool _showCur = false;
  bool _showNew = false;
  bool _showConf = false;
  bool _pwBusy = false;
  String? _pwError;

  bool _isLoading = false;
  final _picker = ImagePicker();
  String? _photoBase64;
  bool _photoChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.currentData['kitchenName'] ?? "Ammi's Kitchen");
    _aboutController =
        TextEditingController(text: widget.currentData['about'] ?? "");
    _cuisineController =
        TextEditingController(text: widget.currentData['cuisine'] ?? "");
    _locationController =
        TextEditingController(text: widget.currentData['location'] ?? "");
    _hoursController =
        TextEditingController(text: widget.currentData['hours'] ?? "");
    _easypaisaController = TextEditingController(
        text: widget.currentData['easypaisaNumber'] ?? "");
    _jazzcashController =
        TextEditingController(text: widget.currentData['jazzcashNumber'] ?? "");
    _accountTitleController =
        TextEditingController(text: widget.currentData['accountTitle'] ?? "");

    final p = widget.currentData['photoBase64'];
    _photoBase64 = (p is String && p.isNotEmpty) ? p : null;

    // Keep the initial-letter avatar in sync while typing the name.
    _nameController.addListener(() {
      if (_photoBase64 == null && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _cuisineController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    _easypaisaController.dispose();
    _jazzcashController.dispose();
    _accountTitleController.dispose();
    _curPw.dispose();
    _newPw.dispose();
    _confPw.dispose();
    super.dispose();
  }

  /// Empty is fine (seller doesn't accept that method); otherwise must be 03XXXXXXXXX.
  String? _phoneOrEmpty(String? v) {
    final t = (v ?? '').trim().replaceAll(RegExp(r'[\s-]'), '');
    if (t.isEmpty) return null;
    return RegExp(r'^03\d{9}$').hasMatch(t)
        ? null
        : 'Enter a valid number, e.g. 03001234567';
  }

  String _clean(String v) => v.trim().replaceAll(RegExp(r'[\s-]'), '');

  // ---------- Photo ----------
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBase64 = base64Encode(bytes);
        _photoChanged = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker.')),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _photoBase64 = null;
                    _photoChanged = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoPicker() {
    final name = _nameController.text.trim();
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _photoBase64 != null
                        ? Image.memory(
                      base64Decode(_photoBase64!),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                        : Container(
                      color: _accent,
                      alignment: Alignment.center,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: _accent,
                    child:
                    Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showPhotoOptions,
            child: const Text('Change photo', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }

  // ---------- Change password (inline) ----------
  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();

    String? problem;
    if (_curPw.text.isEmpty) {
      problem = 'Enter your current password.';
    } else if (_newPw.text.length < 6) {
      problem = 'New password must be at least 6 characters.';
    } else if (_newPw.text == _curPw.text) {
      problem = 'New password must be different from the current one.';
    } else if (_newPw.text != _confPw.text) {
      problem = 'New passwords do not match.';
    }
    if (problem != null) {
      setState(() => _pwError = problem);
      return;
    }

    setState(() {
      _pwBusy = true;
      _pwError = null;
    });

    final err = await changePassword(
      currentPassword: _curPw.text,
      newPassword: _newPw.text,
    );

    if (!mounted) return;
    setState(() => _pwBusy = false);

    if (err != null) {
      setState(() => _pwError = err);
      return;
    }

    _curPw.clear();
    _newPw.clear();
    _confPw.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _pwField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  Widget _passwordSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.lock_outline, color: _accent),
          title: const Text(
            'Change Password',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _pwField(
              label: 'Current password',
              controller: _curPw,
              visible: _showCur,
              onToggle: () => setState(() => _showCur = !_showCur),
            ),
            _pwField(
              label: 'New password',
              controller: _newPw,
              visible: _showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
            ),
            _pwField(
              label: 'Confirm new password',
              controller: _confPw,
              visible: _showConf,
              onToggle: () => setState(() => _showConf = !_showConf),
            ),
            if (_pwError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_pwError!,
                      style: const TextStyle(
                          color: Color(0xFFD94545), fontSize: 13)),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: _pwBusy ? null : _updatePassword,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _accent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _pwBusy
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: _accent),
                )
                    : const Text('Update Password',
                    style: TextStyle(
                        color: _accent, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Save ----------
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String uid =
          FirebaseAuth.instance.currentUser?.uid ?? 'sample_user_id';
      final db = FirebaseFirestore.instance;

      // Only touch the photo field if the user changed it.
      final photoUpdate = <String, dynamic>{
        if (_photoChanged) 'photoBase64': _photoBase64 ?? FieldValue.delete(),
      };

      final profileFields = <String, dynamic>{
        'kitchenName': _nameController.text.trim(),
        'about': _aboutController.text.trim(),
        'cuisine': _cuisineController.text.trim(),
        'location': _locationController.text.trim(),
        'hours': _hoursController.text.trim(),
      };

      await db.collection('kitchens').doc(uid).set({
        ...profileFields,
        'easypaisaNumber': _clean(_easypaisaController.text),
        'jazzcashNumber': _clean(_jazzcashController.text),
        'accountTitle': _accountTitleController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...photoUpdate,
      }, SetOptions(merge: true));

      // Keep users/{uid} in sync for anything that reads the profile from there.
      await db.collection('users').doc(uid).set({
        ...profileFields,
        ...photoUpdate,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _photoPicker(),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Kitchen Name",
                controller: _nameController,
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "About",
                controller: _aboutController,
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter about info'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Cuisine",
                controller: _cuisineController,
                hintText: "e.g. Pakistani, Homemade, Halal",
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Location",
                controller: _locationController,
                hintText: "House no, Block no, Karachi",
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Hours",
                controller: _hoursController,
                hintText: "e.g. 11am – 9pm",
              ),
              const SizedBox(height: 28),

              // ---- Payment accounts ----
              const Text(
                "Payment accounts",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "Customers send money to these numbers and enter the transaction ID. "
                    "Leave a field empty if you don't accept that method.",
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              _buildInputField(
                label: "Easypaisa Number",
                controller: _easypaisaController,
                hintText: "03001234567",
                keyboardType: TextInputType.phone,
                validator: _phoneOrEmpty,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "JazzCash Number",
                controller: _jazzcashController,
                hintText: "03001234567",
                keyboardType: TextInputType.phone,
                validator: _phoneOrEmpty,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "Account Title",
                controller: _accountTitleController,
                hintText: "Name on the account",
              ),
              const SizedBox(height: 28),

              // Change Password (inline, inside Edit Profile)
              _passwordSection(),
              const SizedBox(height: 24),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}