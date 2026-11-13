// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ManageMenuScreen extends StatefulWidget {
//   const ManageMenuScreen({super.key});

//   @override
//   State<ManageMenuScreen> createState() => _ManageMenuScreenState();
// }

// class _ManageMenuScreenState extends State<ManageMenuScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();
//   final TextEditingController _imageUrlController = TextEditingController();
//   final TextEditingController _prepTimeController = TextEditingController();
//   final TextEditingController _servingSizeController = TextEditingController();

//   // String _selectedCategory = 'Main Course';
//   // final List<String> _categories = [
//   //   'Main Course',
//   //   'BBQ & Tikkas',
//   //   'Roti & Naan',
//   //   'Dessert',
//   //   'Beverages',
//   // ];


//   String? _selectedCategory;
//   List<Map<String, String>> _categories = [];

//   String _selectedDietaryTag = 'Regular';
//   final List<String> _dietaryTags = [
//     'Regular',
//     'Spicy',
//     'Zero-Oil / Healthy',
//     'Traditional',
//     'Low-Carb',
//   ];

//   bool _showOnlyTodaysMenu = false;
//   bool _saving = false;

//   @override
//   void initState() {
//     super.initState();
//     _removeDemoDishes();
//   }

//   /// Removes the old auto-generated demo dishes. A dish is deleted only if
//   /// BOTH its name and its demo image match.
//   Future<void> _removeDemoDishes() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     const demoDishes = {
//       'Special Chicken Biryani': 'photo-1563379091339-03b21ab4a4f8',
//       'Home-Style Chicken Karahi': 'photo-1603894584373-5ac82b2ae398',
//       'Chicken Tikka': 'photo-1599487488170-d11ec9c172f0',
//       'Shami Kabab Platter': 'photo-1626777552726-4a6b54c97e46',
//       'Special Daal Fry & Roti': 'photo-1546833999-b9f581a1996d',
//       'Soft Gulab Jamun': 'photo-1601050690597-df0568f70950',
//     };

//     try {
//       final firestore = FirebaseFirestore.instance;
//       final snap = await firestore
//           .collection('kitchens')
//           .doc(uid)
//           .collection('menu')
//           .get();

//       final batch = firestore.batch();
//       var count = 0;
//       for (final d in snap.docs) {
//         final data = d.data();
//         final name = (data['name'] ?? '').toString();
//         final url = (data['imageUrl'] ?? '').toString();
//         final photoId = demoDishes[name];
//         if (photoId != null && url.contains(photoId)) {
//           batch.delete(d.reference);
//           count++;
//         }
//       }
//       if (count > 0) await batch.commit();
//     } catch (e) {
//       debugPrint('Demo dish cleanup failed: $e');
//     }
//   }

//   /// TEMPORARY: keeps one copy of each dish name, deletes the rest.
//   /// Tap the broom icon once, then remove this method and the button.
//   Future<void> _removeDuplicates() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     try {
//       final firestore = FirebaseFirestore.instance;
//       final snap = await firestore
//           .collection('kitchens')
//           .doc(uid)
//           .collection('menu')
//           .get();
//       final seen = <String>{};
//       final batch = firestore.batch();
//       var removed = 0;
//       for (final d in snap.docs) {
//         final key = (d.data()['name'] ?? '').toString().toLowerCase().trim();
//         if (!seen.add(key)) {
//           batch.delete(d.reference);
//           removed++;
//         }
//       }
//       if (removed > 0) await batch.commit();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Duplicates removed: $removed')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Cleanup failed: $e')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _descController.dispose();
//     _imageUrlController.dispose();
//     _prepTimeController.dispose();
//     _servingSizeController.dispose();
//     super.dispose();
//   }

//   void _showAddDishModal(BuildContext context, String currentUserId) {
//     final messenger = ScaffoldMessenger.of(context);

//     _nameController.clear();
//     _priceController.clear();
//     _descController.clear();
//     _imageUrlController.clear();
//     _prepTimeController.clear();
//     _servingSizeController.clear();
//     _selectedCategory = 'Main Course';
//     _selectedDietaryTag = 'Regular';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (BuildContext modalContext) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return GestureDetector(
//               onTap: () => FocusScope.of(modalContext).unfocus(),
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   top: 24,
//                   left: 20,
//                   right: 20,
//                   bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               "Add New Dish",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.close),
//                               onPressed: () => Navigator.pop(modalContext),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             labelText: "Dish Name *",
//                             hintText: "e.g., Chicken Tikka, Biryani",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (val) => val == null || val.trim().isEmpty
//                               ? "Enter dish name"
//                               : null,
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _priceController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   labelText: "Price (PKR) *",
//                                   hintText: "450",
//                                   prefixText: "Rs. ",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 validator: (val) =>
//                                     val == null || val.trim().isEmpty
//                                         ? "Enter price"
//                                         : null,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 initialValue: _selectedCategory,
//                                 decoration: InputDecoration(
//                                   labelText: "Category",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 items: _categories
//                                     .map((cat) => DropdownMenuItem(
//                                           value: cat,
//                                           child: Text(
//                                             cat,
//                                             style:
//                                                 const TextStyle(fontSize: 13),
//                                           ),
//                                         ))
//                                     .toList(),
//                                 onChanged: (val) {
//                                   if (val != null) {
//                                     setModalState(
//                                         () => _selectedCategory = val);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _prepTimeController,
//                                 decoration: InputDecoration(
//                                   labelText: "Prep Time",
//                                   hintText: "e.g., 30 mins",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _servingSizeController,
//                                 decoration: InputDecoration(
//                                   labelText: "Serving Size",
//                                   hintText: "e.g., 1 Person",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         DropdownButtonFormField<String>(
//                           initialValue: _selectedDietaryTag,
//                           decoration: InputDecoration(
//                             labelText: "Dietary Tag / Style",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           items: _dietaryTags
//                               .map((tag) => DropdownMenuItem(
//                                     value: tag,
//                                     child: Text(
//                                       tag,
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                   ))
//                               .toList(),
//                           onChanged: (val) {
//                             if (val != null) {
//                               setModalState(() => _selectedDietaryTag = val);
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _descController,
//                           maxLines: 2,
//                           decoration: InputDecoration(
//                             labelText: "Description",
//                             hintText:
//                                 "Fresh homemade recipe prepared with quality ingredients...",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _imageUrlController,
//                           decoration: InputDecoration(
//                             labelText: "Image URL (Optional)",
//                             hintText: "https://...",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFD95325),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () async {
//                               // Block double taps.
//                               if (_saving) return;
//                               if (!_formKey.currentState!.validate()) return;
//                               _saving = true;

//                               // Read everything BEFORE closing the sheet.
//                               final name = _nameController.text.trim();
//                               final price = double.tryParse(
//                                       _priceController.text.trim()) ??
//                                   0;
//                               final category = _selectedCategory;
//                               final prepTime =
//                                   _prepTimeController.text.trim().isEmpty
//                                       ? '30 mins'
//                                       : _prepTimeController.text.trim();
//                               final servingSize =
//                                   _servingSizeController.text.trim().isEmpty
//                                       ? '1 Serving'
//                                       : _servingSizeController.text.trim();
//                               final dietaryTag = _selectedDietaryTag;
//                               final description = _descController.text.trim();
//                               var imageUrl = _imageUrlController.text.trim();
//                               if (imageUrl.isEmpty) {
//                                 imageUrl =
//                                     'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';
//                               }

//                               Navigator.pop(modalContext);

//                               try {
//                                 await FirebaseFirestore.instance
//                                     .collection('kitchens')
//                                     .doc(currentUserId)
//                                     .collection('menu')
//                                     .add({
//                                   'name': name,
//                                   'price': price,
//                                   'category': category,
//                                   'prepTime': prepTime,
//                                   'servingSize': servingSize,
//                                   'dietaryTag': dietaryTag,
//                                   'description': description,
//                                   'imageUrl': imageUrl,
//                                   'isAvailable': true,
//                                   'isTodaysMenu': true,
//                                   'createdAt': FieldValue.serverTimestamp(),
//                                 });

//                                 if (mounted) {
//                                   messenger.showSnackBar(
//                                     const SnackBar(
//                                       content: Text("Dish added to menu!"),
//                                     ),
//                                   );
//                                 }
//                               } catch (e) {
//                                 if (mounted) {
//                                   messenger.showSnackBar(
//                                     SnackBar(
//                                       content: Text("Error adding dish: $e"),
//                                     ),
//                                   );
//                                 }
//                               } finally {
//                                 _saving = false;
//                               }
//                             },
//                             child: const Text(
//                               "Add Dish to Menu",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     if (currentUserId == null) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF9F6F0),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: const Text(
//             "Manage Menu",
//             style: TextStyle(
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//         ),
//         body: const Center(
//           child: Text("Please sign in to manage your menu."),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F6F0),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Manage Menu",
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         actions: [
//           // TEMPORARY: tap once to delete duplicate dishes, then remove.
//           IconButton(
//             tooltip: 'Remove duplicates',
//             icon: const Icon(Icons.cleaning_services, color: Colors.black87),
//             onPressed: _removeDuplicates,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: const Color(0xFFD95325),
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           "Add Item",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         onPressed: () => _showAddDishModal(context, currentUserId),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: FilterChip(
//                     label: const Center(child: Text("All Dishes")),
//                     selected: !_showOnlyTodaysMenu,
//                     selectedColor:
//                         const Color(0xFFD95325).withValues(alpha: 0.15),
//                     checkmarkColor: const Color(0xFFD95325),
//                     labelStyle: TextStyle(
//                       color: !_showOnlyTodaysMenu
//                           ? const Color(0xFFD95325)
//                           : Colors.black87,
//                       fontWeight: !_showOnlyTodaysMenu
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                     onSelected: (val) {
//                       setState(() => _showOnlyTodaysMenu = false);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: FilterChip(
//                     label: const Center(child: Text("⭐ Today's Menu")),
//                     selected: _showOnlyTodaysMenu,
//                     selectedColor: Colors.amber.withValues(alpha: 0.25),
//                     checkmarkColor: Colors.brown[900],
//                     labelStyle: TextStyle(
//                       color: _showOnlyTodaysMenu
//                           ? Colors.brown[900]
//                           : Colors.black87,
//                       fontWeight: _showOnlyTodaysMenu
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                     onSelected: (val) {
//                       setState(() => _showOnlyTodaysMenu = true);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('kitchens')
//                   .doc(currentUserId)
//                   .collection('menu')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.restaurant_menu,
//                             size: 64, color: Colors.grey[400]),
//                         const SizedBox(height: 12),
//                         Text(
//                           "No menu items added yet.",
//                           style:
//                               TextStyle(fontSize: 16, color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 var menuDocs = snapshot.data!.docs;

//                 if (_showOnlyTodaysMenu) {
//                   menuDocs = menuDocs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     return data['isTodaysMenu'] == true;
//                   }).toList();
//                 }

//                 if (menuDocs.isEmpty) {
//                   return Center(
//                     child: Text(
//                       "No dishes selected for Today's Menu.\nTap the ⭐ on any item to feature it today!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: menuDocs.length,
//                   itemBuilder: (context, index) {
//                     final doc = menuDocs[index];
//                     final data = doc.data() as Map<String, dynamic>;

//                     final String name = data['name'] ?? 'Dish Name';
//                     final double price = (data['price'] ?? 0).toDouble();
//                     final String category = data['category'] ?? 'Main Course';
//                     final String prepTime = data['prepTime'] ?? '30 mins';
//                     final String servingSize =
//                         data['servingSize'] ?? '1 Serving';
//                     final String dietaryTag = data['dietaryTag'] ?? 'Regular';
//                     final String imageUrl = data['imageUrl'] ??
//                         'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';
//                     final bool isAvailable = data['isAvailable'] ?? true;
//                     final bool isTodaysMenu = data['isTodaysMenu'] ?? false;

//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         side: isTodaysMenu
//                             ? const BorderSide(color: Colors.amber, width: 1.5)
//                             : BorderSide.none,
//                       ),
//                       elevation: 1.5,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 imageUrl,
//                                 width: 84,
//                                 height: 84,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Container(
//                                   width: 84,
//                                   height: 84,
//                                   color: Colors.grey[300],
//                                   child: const Icon(Icons.fastfood,
//                                       color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           name,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: isAvailable
//                                                 ? Colors.black87
//                                                 : Colors.grey,
//                                             decoration: isAvailable
//                                                 ? null
//                                                 : TextDecoration.lineThrough,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       IconButton(
//                                         tooltip: isTodaysMenu
//                                             ? "Remove from Today's Menu"
//                                             : "Add to Today's Menu",
//                                         icon: Icon(
//                                           isTodaysMenu
//                                               ? Icons.star
//                                               : Icons.star_border,
//                                           color: isTodaysMenu
//                                               ? Colors.amber[700]
//                                               : Colors.grey[400],
//                                           size: 24,
//                                         ),
//                                         onPressed: () async {
//                                           await doc.reference.update(
//                                               {'isTodaysMenu': !isTodaysMenu});
//                                           if (context.mounted) {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               SnackBar(
//                                                 content: Text(
//                                                   !isTodaysMenu
//                                                       ? "$name added to Today's Menu!"
//                                                       : "$name removed from Today's Menu",
//                                                 ),
//                                                 duration:
//                                                     const Duration(seconds: 1),
//                                               ),
//                                             );
//                                           }
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(Icons.delete_outline,
//                                             color: Colors.redAccent, size: 20),
//                                         onPressed: () async {
//                                           await doc.reference.delete();
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                   Wrap(
//                                     spacing: 6,
//                                     runSpacing: 4,
//                                     children: [
//                                       if (isTodaysMenu)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 6, vertical: 2),
//                                           decoration: BoxDecoration(
//                                             color: Colors.amber[100],
//                                             borderRadius:
//                                                 BorderRadius.circular(6),
//                                           ),
//                                           child: Text(
//                                             "⭐ Today's Special",
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.amber[900],
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 6, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[200],
//                                           borderRadius:
//                                               BorderRadius.circular(6),
//                                         ),
//                                         child: Text(
//                                           category,
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors.grey[700],
//                                           ),
//                                         ),
//                                       ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 6, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFD95325)
//                                               .withValues(alpha: 0.1),
//                                           borderRadius:
//                                               BorderRadius.circular(6),
//                                         ),
//                                         child: Text(
//                                           dietaryTag,
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             color: Color(0xFFD95325),
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.access_time,
//                                           size: 12, color: Colors.grey[600]),
//                                       const SizedBox(width: 3),
//                                       Text(
//                                         prepTime,
//                                         style: TextStyle(
//                                             fontSize: 11,
//                                             color: Colors.grey[600]),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Icon(Icons.room_service_outlined,
//                                           size: 12, color: Colors.grey[600]),
//                                       const SizedBox(width: 3),
//                                       Text(
//                                         servingSize,
//                                         style: TextStyle(
//                                             fontSize: 11,
//                                             color: Colors.grey[600]),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Rs. ${price.toStringAsFixed(0)}",
//                                         style: const TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFFD95325),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             isAvailable
//                                                 ? "In Stock"
//                                                 : "Out of Stock",
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               fontWeight: FontWeight.w600,
//                                               color: isAvailable
//                                                   ? Colors.green
//                                                   : Colors.red,
//                                             ),
//                                           ),
//                                           Switch(
//                                             value: isAvailable,
//                                             activeThumbColor:
//                                                 const Color(0xFFD95325),
//                                             onChanged: (val) async {
//                                               await doc.reference
//                                                   .update({'isAvailable': val});
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ManageMenuScreen extends StatefulWidget {
//   const ManageMenuScreen({super.key});

//   @override
//   State<ManageMenuScreen> createState() => _ManageMenuScreenState();
// }

// class _ManageMenuScreenState extends State<ManageMenuScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();
//   final TextEditingController _imageUrlController = TextEditingController();
//   final TextEditingController _prepTimeController = TextEditingController();
//   final TextEditingController _servingSizeController = TextEditingController();

//   // Categories now come from Firestore (same list the customer app uses).
//   String? _selectedCategory;
//   List<Map<String, String>> _categories = [];

//   String _selectedDietaryTag = 'Regular';
//   final List<String> _dietaryTags = [
//     'Regular',
//     'Spicy',
//     'Zero-Oil / Healthy',
//     'Traditional',
//     'Low-Carb',
//   ];

//   bool _showOnlyTodaysMenu = false;
//   bool _saving = false;

//   @override
//   void initState() {
//     super.initState();
//     _removeDemoDishes();
//     _loadCategories();
//   }

//   /// Same categories the customer app shows.
//   Future<void> _loadCategories() async {
//     try {
//       final snap =
//           await FirebaseFirestore.instance.collection('categories').get();
//       final list = snap.docs
//           .map<Map<String, String>>((d) => {
//                 'id': d.id,
//                 'name': (d.data()['name'] ?? d.id).toString(),
//               })
//           .toList();
//       if (!mounted) return;
//       setState(() => _categories = list);
//     } catch (e) {
//       debugPrint('Could not load categories: $e');
//     }
//   }

//   /// Removes the old auto-generated demo dishes. A dish is deleted only if
//   /// BOTH its name and its demo image match.
//   Future<void> _removeDemoDishes() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     const demoDishes = {
//       'Special Chicken Biryani': 'photo-1563379091339-03b21ab4a4f8',
//       'Home-Style Chicken Karahi': 'photo-1603894584373-5ac82b2ae398',
//       'Chicken Tikka': 'photo-1599487488170-d11ec9c172f0',
//       'Shami Kabab Platter': 'photo-1626777552726-4a6b54c97e46',
//       'Special Daal Fry & Roti': 'photo-1546833999-b9f581a1996d',
//       'Soft Gulab Jamun': 'photo-1601050690597-df0568f70950',
//     };

//     try {
//       final firestore = FirebaseFirestore.instance;
//       final snap = await firestore
//           .collection('kitchens')
//           .doc(uid)
//           .collection('menu')
//           .get();

//       final batch = firestore.batch();
//       var count = 0;
//       for (final d in snap.docs) {
//         final data = d.data();
//         final name = (data['name'] ?? '').toString();
//         final url = (data['imageUrl'] ?? '').toString();
//         final photoId = demoDishes[name];
//         if (photoId != null && url.contains(photoId)) {
//           batch.delete(d.reference);
//           count++;
//         }
//       }
//       if (count > 0) await batch.commit();
//     } catch (e) {
//       debugPrint('Demo dish cleanup failed: $e');
//     }
//   }

//   /// TEMPORARY: keeps one copy of each dish name, deletes the rest.
//   /// Tap the broom icon once, then remove this method and the button.
//   Future<void> _removeDuplicates() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     try {
//       final firestore = FirebaseFirestore.instance;
//       final snap = await firestore
//           .collection('kitchens')
//           .doc(uid)
//           .collection('menu')
//           .get();
//       final seen = <String>{};
//       final batch = firestore.batch();
//       var removed = 0;
//       for (final d in snap.docs) {
//         final key = (d.data()['name'] ?? '').toString().toLowerCase().trim();
//         if (!seen.add(key)) {
//           batch.delete(d.reference);
//           removed++;
//         }
//       }
//       if (removed > 0) await batch.commit();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Duplicates removed: $removed')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Cleanup failed: $e')),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _descController.dispose();
//     _imageUrlController.dispose();
//     _prepTimeController.dispose();
//     _servingSizeController.dispose();
//     super.dispose();
//   }

//   void _showAddDishModal(BuildContext context, String currentUserId) {
//     final messenger = ScaffoldMessenger.of(context);

//     _nameController.clear();
//     _priceController.clear();
//     _descController.clear();
//     _imageUrlController.clear();
//     _prepTimeController.clear();
//     _servingSizeController.clear();
//     _selectedCategory = _categories.isNotEmpty ? _categories.first['id'] : null;
//     _selectedDietaryTag = 'Regular';

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (BuildContext modalContext) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return GestureDetector(
//               onTap: () => FocusScope.of(modalContext).unfocus(),
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   top: 24,
//                   left: 20,
//                   right: 20,
//                   bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               "Add New Dish",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.close),
//                               onPressed: () => Navigator.pop(modalContext),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: InputDecoration(
//                             labelText: "Dish Name *",
//                             hintText: "e.g., Chicken Tikka, Biryani",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator: (val) => val == null || val.trim().isEmpty
//                               ? "Enter dish name"
//                               : null,
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _priceController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   labelText: "Price (PKR) *",
//                                   hintText: "450",
//                                   prefixText: "Rs. ",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 validator: (val) =>
//                                     val == null || val.trim().isEmpty
//                                         ? "Enter price"
//                                         : null,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: DropdownButtonFormField<String>(
//                                 initialValue: _selectedCategory,
//                                 isExpanded: true,
//                                 decoration: InputDecoration(
//                                   labelText: "Category",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 items: _categories
//                                     .map((c) => DropdownMenuItem<String>(
//                                           value: c['id']!,
//                                           child: Text(
//                                             c['name']!,
//                                             style:
//                                                 const TextStyle(fontSize: 13),
//                                           ),
//                                         ))
//                                     .toList(),
//                                 onChanged: (val) {
//                                   if (val != null) {
//                                     setModalState(
//                                         () => _selectedCategory = val);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _prepTimeController,
//                                 decoration: InputDecoration(
//                                   labelText: "Prep Time",
//                                   hintText: "e.g., 30 mins",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _servingSizeController,
//                                 decoration: InputDecoration(
//                                   labelText: "Serving Size",
//                                   hintText: "e.g., 1 Person",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         DropdownButtonFormField<String>(
//                           initialValue: _selectedDietaryTag,
//                           decoration: InputDecoration(
//                             labelText: "Dietary Tag / Style",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           items: _dietaryTags
//                               .map((tag) => DropdownMenuItem(
//                                     value: tag,
//                                     child: Text(
//                                       tag,
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                   ))
//                               .toList(),
//                           onChanged: (val) {
//                             if (val != null) {
//                               setModalState(() => _selectedDietaryTag = val);
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _descController,
//                           maxLines: 2,
//                           decoration: InputDecoration(
//                             labelText: "Description",
//                             hintText:
//                                 "Fresh homemade recipe prepared with quality ingredients...",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _imageUrlController,
//                           decoration: InputDecoration(
//                             labelText: "Image URL (Optional)",
//                             hintText: "https://...",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFD95325),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () async {
//                               // Block double taps.
//                               if (_saving) return;
//                               if (!_formKey.currentState!.validate()) return;
//                               _saving = true;

//                               // Read everything BEFORE closing the sheet.
//                               final name = _nameController.text.trim();
//                               final price = double.tryParse(
//                                       _priceController.text.trim()) ??
//                                   0;
//                               final category = _selectedCategory ?? '';
//                               final prepTime =
//                                   _prepTimeController.text.trim().isEmpty
//                                       ? '30 mins'
//                                       : _prepTimeController.text.trim();
//                               final servingSize =
//                                   _servingSizeController.text.trim().isEmpty
//                                       ? '1 Serving'
//                                       : _servingSizeController.text.trim();
//                               final dietaryTag = _selectedDietaryTag;
//                               final description = _descController.text.trim();
//                               var imageUrl = _imageUrlController.text.trim();
//                               if (imageUrl.isEmpty) {
//                                 imageUrl =
//                                     'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';
//                               }

//                               Navigator.pop(modalContext);

//                               try {
//                                 await FirebaseFirestore.instance
//                                     .collection('kitchens')
//                                     .doc(currentUserId)
//                                     .collection('menu')
//                                     .add({
//                                   'name': name,
//                                   'price': price,
//                                   'category': category,
//                                   'prepTime': prepTime,
//                                   'servingSize': servingSize,
//                                   'dietaryTag': dietaryTag,
//                                   'description': description,
//                                   'imageUrl': imageUrl,
//                                   'isAvailable': true,
//                                   'isTodaysMenu': true,
//                                   'createdAt': FieldValue.serverTimestamp(),
//                                 });

//                                 if (mounted) {
//                                   messenger.showSnackBar(
//                                     const SnackBar(
//                                       content: Text("Dish added to menu!"),
//                                     ),
//                                   );
//                                 }
//                               } catch (e) {
//                                 if (mounted) {
//                                   messenger.showSnackBar(
//                                     SnackBar(
//                                       content: Text("Error adding dish: $e"),
//                                     ),
//                                   );
//                                 }
//                               } finally {
//                                 _saving = false;
//                               }
//                             },
//                             child: const Text(
//                               "Add Dish to Menu",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     if (currentUserId == null) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF9F6F0),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: const Text(
//             "Manage Menu",
//             style: TextStyle(
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//         ),
//         body: const Center(
//           child: Text("Please sign in to manage your menu."),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F6F0),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Manage Menu",
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         actions: [
//           // TEMPORARY: tap once to delete duplicate dishes, then remove.
//           IconButton(
//             tooltip: 'Remove duplicates',
//             icon: const Icon(Icons.cleaning_services, color: Colors.black87),
//             onPressed: _removeDuplicates,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: const Color(0xFFD95325),
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           "Add Item",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         onPressed: () => _showAddDishModal(context, currentUserId),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: FilterChip(
//                     label: const Center(child: Text("All Dishes")),
//                     selected: !_showOnlyTodaysMenu,
//                     selectedColor:
//                         const Color(0xFFD95325).withValues(alpha: 0.15),
//                     checkmarkColor: const Color(0xFFD95325),
//                     labelStyle: TextStyle(
//                       color: !_showOnlyTodaysMenu
//                           ? const Color(0xFFD95325)
//                           : Colors.black87,
//                       fontWeight: !_showOnlyTodaysMenu
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                     onSelected: (val) {
//                       setState(() => _showOnlyTodaysMenu = false);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: FilterChip(
//                     label: const Center(child: Text("⭐ Today's Menu")),
//                     selected: _showOnlyTodaysMenu,
//                     selectedColor: Colors.amber.withValues(alpha: 0.25),
//                     checkmarkColor: Colors.brown[900],
//                     labelStyle: TextStyle(
//                       color: _showOnlyTodaysMenu
//                           ? Colors.brown[900]
//                           : Colors.black87,
//                       fontWeight: _showOnlyTodaysMenu
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                     onSelected: (val) {
//                       setState(() => _showOnlyTodaysMenu = true);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('kitchens')
//                   .doc(currentUserId)
//                   .collection('menu')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.restaurant_menu,
//                             size: 64, color: Colors.grey[400]),
//                         const SizedBox(height: 12),
//                         Text(
//                           "No menu items added yet.",
//                           style:
//                               TextStyle(fontSize: 16, color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 var menuDocs = snapshot.data!.docs;

//                 if (_showOnlyTodaysMenu) {
//                   menuDocs = menuDocs.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     return data['isTodaysMenu'] == true;
//                   }).toList();
//                 }

//                 if (menuDocs.isEmpty) {
//                   return Center(
//                     child: Text(
//                       "No dishes selected for Today's Menu.\nTap the ⭐ on any item to feature it today!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: menuDocs.length,
//                   itemBuilder: (context, index) {
//                     final doc = menuDocs[index];
//                     final data = doc.data() as Map<String, dynamic>;

//                     final String name = data['name'] ?? 'Dish Name';
//                     final double price = (data['price'] ?? 0).toDouble();
//                     final String catId = (data['category'] ?? '').toString();
//                     final String category = _categories.firstWhere(
//                       (c) => c['id'] == catId,
//                       orElse: () =>
//                           {'name': catId.isEmpty ? 'Other' : catId},
//                     )['name']!;
//                     final String prepTime = data['prepTime'] ?? '30 mins';
//                     final String servingSize =
//                         data['servingSize'] ?? '1 Serving';
//                     final String dietaryTag = data['dietaryTag'] ?? 'Regular';
//                     final String imageUrl = data['imageUrl'] ??
//                         'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';
//                     final bool isAvailable = data['isAvailable'] ?? true;
//                     final bool isTodaysMenu = data['isTodaysMenu'] ?? false;

//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         side: isTodaysMenu
//                             ? const BorderSide(color: Colors.amber, width: 1.5)
//                             : BorderSide.none,
//                       ),
//                       elevation: 1.5,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 imageUrl,
//                                 width: 84,
//                                 height: 84,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Container(
//                                   width: 84,
//                                   height: 84,
//                                   color: Colors.grey[300],
//                                   child: const Icon(Icons.fastfood,
//                                       color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           name,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: isAvailable
//                                                 ? Colors.black87
//                                                 : Colors.grey,
//                                             decoration: isAvailable
//                                                 ? null
//                                                 : TextDecoration.lineThrough,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       IconButton(
//                                         tooltip: isTodaysMenu
//                                             ? "Remove from Today's Menu"
//                                             : "Add to Today's Menu",
//                                         icon: Icon(
//                                           isTodaysMenu
//                                               ? Icons.star
//                                               : Icons.star_border,
//                                           color: isTodaysMenu
//                                               ? Colors.amber[700]
//                                               : Colors.grey[400],
//                                           size: 24,
//                                         ),
//                                         onPressed: () async {
//                                           await doc.reference.update(
//                                               {'isTodaysMenu': !isTodaysMenu});
//                                           if (context.mounted) {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               SnackBar(
//                                                 content: Text(
//                                                   !isTodaysMenu
//                                                       ? "$name added to Today's Menu!"
//                                                       : "$name removed from Today's Menu",
//                                                 ),
//                                                 duration:
//                                                     const Duration(seconds: 1),
//                                               ),
//                                             );
//                                           }
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(Icons.delete_outline,
//                                             color: Colors.redAccent, size: 20),
//                                         onPressed: () async {
//                                           await doc.reference.delete();
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                   Wrap(
//                                     spacing: 6,
//                                     runSpacing: 4,
//                                     children: [
//                                       if (isTodaysMenu)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 6, vertical: 2),
//                                           decoration: BoxDecoration(
//                                             color: Colors.amber[100],
//                                             borderRadius:
//                                                 BorderRadius.circular(6),
//                                           ),
//                                           child: Text(
//                                             "⭐ Today's Special",
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.amber[900],
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 6, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[200],
//                                           borderRadius:
//                                               BorderRadius.circular(6),
//                                         ),
//                                         child: Text(
//                                           category,
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                             color: Colors.grey[700],
//                                           ),
//                                         ),
//                                       ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 6, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFD95325)
//                                               .withValues(alpha: 0.1),
//                                           borderRadius:
//                                               BorderRadius.circular(6),
//                                         ),
//                                         child: Text(
//                                           dietaryTag,
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             color: Color(0xFFD95325),
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.access_time,
//                                           size: 12, color: Colors.grey[600]),
//                                       const SizedBox(width: 3),
//                                       Text(
//                                         prepTime,
//                                         style: TextStyle(
//                                             fontSize: 11,
//                                             color: Colors.grey[600]),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Icon(Icons.room_service_outlined,
//                                           size: 12, color: Colors.grey[600]),
//                                       const SizedBox(width: 3),
//                                       Text(
//                                         servingSize,
//                                         style: TextStyle(
//                                             fontSize: 11,
//                                             color: Colors.grey[600]),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Rs. ${price.toStringAsFixed(0)}",
//                                         style: const TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFFD95325),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             isAvailable
//                                                 ? "In Stock"
//                                                 : "Out of Stock",
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               fontWeight: FontWeight.w600,
//                                               color: isAvailable
//                                                   ? Colors.green
//                                                   : Colors.red,
//                                             ),
//                                           ),
//                                           Switch(
//                                             value: isAvailable,
//                                             activeThumbColor:
//                                                 const Color(0xFFD95325),
//                                             onChanged: (val) async {
//                                               await doc.reference
//                                                   .update({'isAvailable': val});
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageMenuScreen extends StatefulWidget {
  const ManageMenuScreen({super.key});

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();

  static const String _defaultImage =
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c';

  // Categories now come from Firestore (same list the customer app uses).
  String? _selectedCategory;
  List<Map<String, String>> _categories = [];

  String _selectedDietaryTag = 'Regular';
  final List<String> _dietaryTags = [
    'Regular',
    'Spicy',
    'Zero-Oil / Healthy',
    'Traditional',
    'Low-Carb',
  ];

  bool _showOnlyTodaysMenu = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _removeDemoDishes();
    _loadCategories();
  }

  /// Same categories the customer app shows.
  Future<void> _loadCategories() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('categories').get();
      final list = snap.docs
          .map<Map<String, String>>((d) => {
                'id': d.id,
                'name': (d.data()['name'] ?? d.id).toString(),
              })
          .toList();
      if (!mounted) return;
      setState(() => _categories = list);
    } catch (e) {
      debugPrint('Could not load categories: $e');
    }
  }

  /// Removes the old auto-generated demo dishes. A dish is deleted only if
  /// BOTH its name and its demo image match.
  Future<void> _removeDemoDishes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    const demoDishes = {
      'Special Chicken Biryani': 'photo-1563379091339-03b21ab4a4f8',
      'Home-Style Chicken Karahi': 'photo-1603894584373-5ac82b2ae398',
      'Chicken Tikka': 'photo-1599487488170-d11ec9c172f0',
      'Shami Kabab Platter': 'photo-1626777552726-4a6b54c97e46',
      'Special Daal Fry & Roti': 'photo-1546833999-b9f581a1996d',
      'Soft Gulab Jamun': 'photo-1601050690597-df0568f70950',
    };

    try {
      final firestore = FirebaseFirestore.instance;
      final snap = await firestore
          .collection('kitchens')
          .doc(uid)
          .collection('menu')
          .get();

      final batch = firestore.batch();
      var count = 0;
      for (final d in snap.docs) {
        final data = d.data();
        final name = (data['name'] ?? '').toString();
        final url = (data['imageUrl'] ?? '').toString();
        final photoId = demoDishes[name];
        if (photoId != null && url.contains(photoId)) {
          batch.delete(d.reference);
          count++;
        }
      }
      if (count > 0) await batch.commit();
    } catch (e) {
      debugPrint('Demo dish cleanup failed: $e');
    }
  }

  /// TEMPORARY: keeps one copy of each dish name, deletes the rest.
  /// Tap the broom icon once, then remove this method and the button.
  Future<void> _removeDuplicates() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final snap = await firestore
          .collection('kitchens')
          .doc(uid)
          .collection('menu')
          .get();
      final seen = <String>{};
      final batch = firestore.batch();
      var removed = 0;
      for (final d in snap.docs) {
        final key = (d.data()['name'] ?? '').toString().toLowerCase().trim();
        if (!seen.add(key)) {
          batch.delete(d.reference);
          removed++;
        }
      }
      if (removed > 0) await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicates removed: $removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cleanup failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  /// Image URL must be a direct https link to a picture, not a web page.
  String? _validateImageUrl(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null; // optional
    final u = Uri.tryParse(t);
    if (u == null || u.scheme != 'https' || u.host.isEmpty) {
      return 'Use a direct https:// image link';
    }
    const pageHosts = ['google.', 'pinterest.', 'facebook.', 'instagram.'];
    if (pageHosts.any(u.host.contains) ||
        u.host == 'unsplash.com' ||
        u.host == 'www.unsplash.com') {
      return 'That is a web page, not an image. Use "Copy image address"';
    }
    return null;
  }

  void _showAddDishModal(BuildContext context, String currentUserId) {
    final messenger = ScaffoldMessenger.of(context);

    _nameController.clear();
    _priceController.clear();
    _descController.clear();
    _imageUrlController.clear();
    _prepTimeController.clear();
    _servingSizeController.clear();
    _selectedCategory = _categories.isNotEmpty ? _categories.first['id'] : null;
    _selectedDietaryTag = 'Regular';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GestureDetector(
              onTap: () => FocusScope.of(modalContext).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Add New Dish",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Dish Name *",
                            hintText: "e.g., Chicken Tikka, Biryani",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? "Enter dish name"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Price (PKR) *",
                                  hintText: "450",
                                  prefixText: "Rs. ",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? "Enter price"
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Category",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _categories
                                    .map((c) => DropdownMenuItem<String>(
                                          value: c['id']!,
                                          child: Text(
                                            c['name']!,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(
                                        () => _selectedCategory = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _prepTimeController,
                                decoration: InputDecoration(
                                  labelText: "Prep Time",
                                  hintText: "e.g., 30 mins",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _servingSizeController,
                                decoration: InputDecoration(
                                  labelText: "Serving Size",
                                  hintText: "e.g., 1 Person",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDietaryTag,
                          decoration: InputDecoration(
                            labelText: "Dietary Tag / Style",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _dietaryTags
                              .map((tag) => DropdownMenuItem(
                                    value: tag,
                                    child: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => _selectedDietaryTag = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: "Description",
                            hintText:
                                "Fresh homemade recipe prepared with quality ingredients...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _imageUrlController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: "Image URL (Optional)",
                            hintText: "https://...",
                            helperText:
                                'Right-click image → "Copy image address"',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: _validateImageUrl,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD95325),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              // Block double taps.
                              if (_saving) return;
                              if (!_formKey.currentState!.validate()) return;
                              _saving = true;

                              // Read everything BEFORE closing the sheet.
                              final name = _nameController.text.trim();
                              final price = double.tryParse(
                                      _priceController.text.trim()) ??
                                  0;
                              final category = _selectedCategory ?? '';
                              final prepTime =
                                  _prepTimeController.text.trim().isEmpty
                                      ? '30 mins'
                                      : _prepTimeController.text.trim();
                              final servingSize =
                                  _servingSizeController.text.trim().isEmpty
                                      ? '1 Serving'
                                      : _servingSizeController.text.trim();
                              final dietaryTag = _selectedDietaryTag;
                              final description = _descController.text.trim();
                              var imageUrl = _imageUrlController.text.trim();
                              if (imageUrl.isEmpty) {
                                imageUrl = _defaultImage;
                              }

                              Navigator.pop(modalContext);

                              try {
                                await FirebaseFirestore.instance
                                    .collection('kitchens')
                                    .doc(currentUserId)
                                    .collection('menu')
                                    .add({
                                  'name': name,
                                  'price': price,
                                  'category': category,
                                  'prepTime': prepTime,
                                  'servingSize': servingSize,
                                  'dietaryTag': dietaryTag,
                                  'description': description,
                                  'imageUrl': imageUrl,
                                  'isAvailable': true,
                                  'isTodaysMenu': true,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                if (mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text("Dish added to menu!"),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Error adding dish: $e"),
                                    ),
                                  );
                                }
                              } finally {
                                _saving = false;
                              }
                            },
                            child: const Text(
                              "Add Dish to Menu",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Manage Menu",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: const Center(
          child: Text("Please sign in to manage your menu."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Manage Menu",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // TEMPORARY: tap once to delete duplicate dishes, then remove.
          IconButton(
            tooltip: 'Remove duplicates',
            icon: const Icon(Icons.cleaning_services, color: Colors.black87),
            onPressed: _removeDuplicates,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD95325),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Item",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddDishModal(context, currentUserId),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text("All Dishes")),
                    selected: !_showOnlyTodaysMenu,
                    selectedColor:
                        const Color(0xFFD95325).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFFD95325),
                    labelStyle: TextStyle(
                      color: !_showOnlyTodaysMenu
                          ? const Color(0xFFD95325)
                          : Colors.black87,
                      fontWeight: !_showOnlyTodaysMenu
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() => _showOnlyTodaysMenu = false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text("⭐ Today's Menu")),
                    selected: _showOnlyTodaysMenu,
                    selectedColor: Colors.amber.withValues(alpha: 0.25),
                    checkmarkColor: Colors.brown[900],
                    labelStyle: TextStyle(
                      color: _showOnlyTodaysMenu
                          ? Colors.brown[900]
                          : Colors.black87,
                      fontWeight: _showOnlyTodaysMenu
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() => _showOnlyTodaysMenu = true);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kitchens')
                  .doc(currentUserId)
                  .collection('menu')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          "No menu items added yet.",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                var menuDocs = snapshot.data!.docs;

                if (_showOnlyTodaysMenu) {
                  menuDocs = menuDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isTodaysMenu'] == true;
                  }).toList();
                }

                if (menuDocs.isEmpty) {
                  return Center(
                    child: Text(
                      "No dishes selected for Today's Menu.\nTap the ⭐ on any item to feature it today!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuDocs.length,
                  itemBuilder: (context, index) {
                    final doc = menuDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String name = data['name'] ?? 'Dish Name';
                    final double price = (data['price'] ?? 0).toDouble();
                    final String catId = (data['category'] ?? '').toString();
                    final String category = _categories.firstWhere(
                      (c) => c['id'] == catId,
                      orElse: () =>
                          {'name': catId.isEmpty ? 'Other' : catId},
                    )['name']!;
                    final String prepTime = data['prepTime'] ?? '30 mins';
                    final String servingSize =
                        data['servingSize'] ?? '1 Serving';
                    final String dietaryTag = data['dietaryTag'] ?? 'Regular';
                    final String rawImage =
                        (data['imageUrl'] ?? '').toString().trim();
                    final String imageUrl =
                        rawImage.isEmpty ? _defaultImage : rawImage;
                    final bool isAvailable = data['isAvailable'] ?? true;
                    final bool isTodaysMenu = data['isTodaysMenu'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isTodaysMenu
                            ? const BorderSide(color: Colors.amber, width: 1.5)
                            : BorderSide.none,
                      ),
                      elevation: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _DishImage(url: imageUrl, size: 84),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isAvailable
                                                ? Colors.black87
                                                : Colors.grey,
                                            decoration: isAvailable
                                                ? null
                                                : TextDecoration.lineThrough,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: isTodaysMenu
                                            ? "Remove from Today's Menu"
                                            : "Add to Today's Menu",
                                        icon: Icon(
                                          isTodaysMenu
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: isTodaysMenu
                                              ? Colors.amber[700]
                                              : Colors.grey[400],
                                          size: 24,
                                        ),
                                        onPressed: () async {
                                          await doc.reference.update(
                                              {'isTodaysMenu': !isTodaysMenu});
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  !isTodaysMenu
                                                      ? "$name added to Today's Menu!"
                                                      : "$name removed from Today's Menu",
                                                ),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.redAccent, size: 20),
                                        onPressed: () async {
                                          await doc.reference.delete();
                                        },
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (isTodaysMenu)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber[100],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "⭐ Today's Special",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.amber[900],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD95325)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          dietaryTag,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFFD95325),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 12, color: Colors.grey[600]),
                                      const SizedBox(width: 3),
                                      Text(
                                        prepTime,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(Icons.room_service_outlined,
                                          size: 12, color: Colors.grey[600]),
                                      const SizedBox(width: 3),
                                      Text(
                                        servingSize,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rs. ${price.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD95325),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            isAvailable
                                                ? "In Stock"
                                                : "Out of Stock",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isAvailable
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          Switch(
                                            value: isAvailable,
                                            activeThumbColor:
                                                const Color(0xFFD95325),
                                            onChanged: (val) async {
                                              await doc.reference
                                                  .update({'isAvailable': val});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Network image with a loading state, a visible error placeholder and a
/// console log of the failing URL, so broken links are easy to diagnose.
class _DishImage extends StatelessWidget {
  final String url;
  final double size;
  const _DishImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    Widget placeholder([IconData icon = Icons.fastfood]) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(icon, color: Colors.grey),
        );

    return Image.network(
      url.trim(),
      width: size,
      height: size,
      fit: BoxFit.cover,
      // Fixes most "image blank on Chrome" cases (CORS).
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder(Icons.image_outlined),
      errorBuilder: (context, error, stack) {
        debugPrint('Image failed to load: $url -> $error');
        return placeholder(Icons.broken_image_outlined);
      },
    );
  }
}