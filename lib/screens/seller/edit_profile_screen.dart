// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EditProfileScreen extends StatefulWidget {
//   final Map<String, dynamic> currentData;

//   const EditProfileScreen({Key? key, required this.currentData}) : super(key: key);

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController _nameController;
//   late TextEditingController _aboutController;
//   late TextEditingController _cuisineController;
//   late TextEditingController _locationController;
//   late TextEditingController _hoursController;

//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.currentData['kitchenName'] ?? "Ammi's Kitchen");
//     _aboutController = TextEditingController(text: widget.currentData['about'] ?? "");
//     _cuisineController = TextEditingController(text: widget.currentData['cuisine'] ?? "");
//     _locationController = TextEditingController(text: widget.currentData['location'] ?? "");
//     _hoursController = TextEditingController(text: widget.currentData['hours'] ?? "");
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _aboutController.dispose();
//     _cuisineController.dispose();
//     _locationController.dispose();
//     _hoursController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'sample_user_id';

//       // Save / Update details in Firestore under the 'kitchens' collection
//       await FirebaseFirestore.instance.collection('kitchens').doc(uid).set({
//         'kitchenName': _nameController.text.trim(),
//         'about': _aboutController.text.trim(),
//         'cuisine': _cuisineController.text.trim(),
//         'location': _locationController.text.trim(),
//         'hours': _hoursController.text.trim(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context); // Go back to profile screen
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update profile: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F6F0),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Edit Profile",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildInputField(
//                 label: "Kitchen Name",
//                 controller: _nameController,
//                 validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
//               ),
//               const SizedBox(height: 16),
//               _buildInputField(
//                 label: "About",
//                 controller: _aboutController,
//                 maxLines: 4,
//                 validator: (val) => val == null || val.isEmpty ? 'Please enter about info' : null,
//               ),
//               const SizedBox(height: 16),
//               _buildInputField(
//                 label: "Cuisine",
//                 controller: _cuisineController,
//                 hintText: "e.g. Pakistani, Homemade, Halal",
//               ),
//               const SizedBox(height: 16),
//               _buildInputField(
//                 label: "Location",
//                 controller: _locationController,
//                 hintText: "e.g. DHA Phase 6, Karachi",
//               ),
//               const SizedBox(height: 16),
//               _buildInputField(
//                 label: "Hours",
//                 controller: _hoursController,
//                 hintText: "e.g. 11am – 9pm",
//               ),
//               const SizedBox(height: 32),

//               // Save Changes Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFD95325),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                     "Save Changes",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required String label,
//     required TextEditingController controller,
//     String? hintText,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hintText,
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFFD95325), width: 1.5),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({Key? key, required this.currentData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _cuisineController;
  late TextEditingController _locationController;
  late TextEditingController _hoursController;
  late TextEditingController _easypaisaController;
  late TextEditingController _jazzcashController;
  late TextEditingController _accountTitleController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentData['kitchenName'] ?? "Ammi's Kitchen");
    _aboutController = TextEditingController(text: widget.currentData['about'] ?? "");
    _cuisineController = TextEditingController(text: widget.currentData['cuisine'] ?? "");
    _locationController = TextEditingController(text: widget.currentData['location'] ?? "");
    _hoursController = TextEditingController(text: widget.currentData['hours'] ?? "");
    _easypaisaController = TextEditingController(text: widget.currentData['easypaisaNumber'] ?? "");
    _jazzcashController = TextEditingController(text: widget.currentData['jazzcashNumber'] ?? "");
    _accountTitleController = TextEditingController(text: widget.currentData['accountTitle'] ?? "");
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'sample_user_id';

      // Save / Update details in Firestore under the 'kitchens' collection
      await FirebaseFirestore.instance.collection('kitchens').doc(uid).set({
        'kitchenName': _nameController.text.trim(),
        'about': _aboutController.text.trim(),
        'cuisine': _cuisineController.text.trim(),
        'location': _locationController.text.trim(),
        'hours': _hoursController.text.trim(),
        'easypaisaNumber': _clean(_easypaisaController.text),
        'jazzcashNumber': _clean(_jazzcashController.text),
        'accountTitle': _accountTitleController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to profile screen
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                label: "Kitchen Name",
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: "About",
                controller: _aboutController,
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty ? 'Please enter about info' : null,
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
                hintText: "e.g. DHA Phase 6, Karachi",
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
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
              const SizedBox(height: 32),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD95325),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFFD95325), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}