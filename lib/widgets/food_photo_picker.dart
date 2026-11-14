import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'food_image.dart';

/// value: the current photo ('' or null = none, shows the default image).
/// onChanged: called with the new photo, or '' when it is removed.
class FoodPhotoPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const FoodPhotoPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _accent = Color(0xFFD95325);

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 65,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      onChanged('data:image/jpeg;base64,${base64Encode(bytes)}');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker.')),
      );
    }
  }

  void _showOptions(BuildContext context) {
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
                _pick(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pick(context, ImageSource.camera);
              },
            ),
            if ((value ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  onChanged('');
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (value ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food photo',
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showOptions(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                FoodImage(
                  imageUrl: value,
                  width: double.infinity,
                  height: 180,
                ),
                const Positioned(
                  right: 10,
                  bottom: 10,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _accent,
                    child:
                    Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasPhoto
              ? 'Tap the photo to change or remove it.'
              : 'No photo yet. Customers will see the default image.',
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}