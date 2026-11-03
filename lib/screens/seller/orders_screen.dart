import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Filter state: 'all', 'active', 'completed'
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'lzkxn1tnC8SiZYDWa6uodfD7CO72';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Customer Orders",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Bar (3 Clean Buttons)
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Active', 'active'),
                _buildFilterChip('Delivered', 'completed'),
              ],
            ),
          ),

          // Orders Stream List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('kitchenId', isEqualTo: currentUserId)
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
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          "No orders received yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                var orderDocs = snapshot.data!.docs;

                // Client-side filtering for 3 tabs
                if (_selectedFilter != 'all') {
                  orderDocs = orderDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'new';

                    if (_selectedFilter == 'active') {
                      // Active includes new, preparing, and ready
                      return status == 'new' || status == 'preparing' || status == 'ready';
                    } else if (_selectedFilter == 'completed') {
                      // Delivered / Completed tab
                      return status == 'completed';
                    }
                    return status == _selectedFilter;
                  }).toList();
                }

                if (orderDocs.isEmpty) {
                  return Center(
                    child: Text(
                      "No ${_selectedFilter} orders found.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderDocs.length,
                  itemBuilder: (context, index) {
                    final doc = orderDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String orderId = doc.id;
                    final String customerName = data['customerName'] ?? 'Valued Customer';
                    final String customerPhone = data['customerPhone'] ?? 'N/A';
                    final double totalAmount = (data['totalAmount'] ?? 0).toDouble();
                    final String status = data['status'] ?? 'new';
                    final List items = data['items'] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Order ID & Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order #${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length).toUpperCase()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            const Divider(height: 20),

                            // Customer Info
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const Spacer(),
                                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(customerPhone, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Items Ordered List Box
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: items.map<Widget>((item) {
                                  final itemName = item['name'] ?? 'Dish';
                                  final quantity = item['quantity'] ?? 1;
                                  final price = item['price'] ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("$quantity x $itemName", style: const TextStyle(fontSize: 13)),
                                        Text("Rs. ${price * quantity}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Total Amount & Action Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Total Amount", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text(
                                      "Rs. ${totalAmount.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD95325),
                                      ),
                                    ),
                                  ],
                                ),

                                // Status Action Handler
                                _buildActionButtons(doc.reference, status),
                              ],
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

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFD95325).withOpacity(0.15),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFD95325) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label = status.toUpperCase();

    switch (status) {
      case 'new':
        bgColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        label = 'NEW';
        break;
      case 'preparing':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        label = 'PREPARING';
        break;
      case 'ready':
        bgColor = Colors.purple[100]!;
        textColor = Colors.purple[900]!;
        label = 'READY';
        break;
      case 'completed':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        label = 'COMPLETED';
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildActionButtons(DocumentReference docRef, String status) {
    if (status == 'new') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: () async {
              await docRef.update({'status': 'cancelled'});
            },
            child: const Text("Reject", style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD95325),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: () async {
              await docRef.update({'status': 'preparing'});
            },
            child: const Text("Accept", style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ],
      );
    } else if (status == 'preparing') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          await docRef.update({'status': 'ready'});
        },
        child: const Text("Mark Ready", style: TextStyle(fontSize: 12, color: Colors.white)),
      );
    } else if (status == 'ready') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          await docRef.update({'status': 'completed'});
        },
        child: const Text("Complete", style: TextStyle(fontSize: 12, color: Colors.white)),
      );
    } else {
      return const Text("Done", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic));
    }
  }
}