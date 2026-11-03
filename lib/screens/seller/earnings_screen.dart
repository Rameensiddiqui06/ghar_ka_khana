import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Optional if you use date formatting, or we can use pure Dart logic

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  // Toggle between view modes or display all in one comprehensive dashboard
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'lzkxn1tnC8SiZYDWa6uodfD7CO72';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Earnings & Analytics",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('kitchenId', isEqualTo: currentUserId)
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
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text("No earnings data yet.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          var orderDocs = snapshot.data!.docs;

          // Time calculations
          final now = DateTime.now();
          double dailyRevenue = 0;
          double weeklyRevenue = 0;
          double monthlyRevenue = 0;

          // Map to track today's item sales breakdown: itemName -> {'qty': int, 'revenue': double}
          Map<String, Map<String, dynamic>> dailyItemBreakdown = {};
          String topEarningItemToday = 'No sales today';
          double maxItemRevenueToday = 0;

          for (var doc in orderDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final double totalAmount = (data['totalAmount'] ?? 0).toDouble();
            final String status = data['status'] ?? 'new';

            // Only count completed/delivered orders toward revenue
            if (status != 'completed') continue;

            // Handle timestamp parsing safely
            DateTime? orderDate;
            var rawTimestamp = data['createdAt'];
            if (rawTimestamp is Timestamp) {
              orderDate = rawTimestamp.toDate();
            } else {
              orderDate = DateTime.now(); // Fallback if timestamp is missing
            }

            // 1. Daily Revenue (orders from today)
            if (orderDate.year == now.year && orderDate.month == now.month && orderDate.day == now.day) {
              dailyRevenue += totalAmount;

              // Parse items for daily breakdown receipt & top item calculation
              final List items = data['items'] ?? [];
              for (var item in items) {
                final String itemName = item['name'] ?? 'Unknown Dish';
                final int qty = (item['quantity'] ?? 1);
                final double price = (item['price'] ?? 0).toDouble();
                final double itemTotal = price * qty;

                if (dailyItemBreakdown.containsKey(itemName)) {
                  dailyItemBreakdown[itemName]!['qty'] += qty;
                  dailyItemBreakdown[itemName]!['revenue'] += itemTotal;
                } else {
                  dailyItemBreakdown[itemName] = {
                    'qty': qty,
                    'revenue': itemTotal,
                  };
                }
              }
            }

            // 2. Weekly Revenue (orders within the last 7 days)
            if (now.difference(orderDate).inDays <= 7) {
              weeklyRevenue += totalAmount;
            }

            // 3. Monthly Revenue (orders in current month & year)
            if (orderDate.year == now.year && orderDate.month == now.month) {
              monthlyRevenue += totalAmount;
            }
          }

          // Determine top earning item for today
          dailyItemBreakdown.forEach((name, details) {
            double rev = details['revenue'];
            if (rev > maxItemRevenueToday) {
              maxItemRevenueToday = rev;
              topEarningItemToday = name;
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Overview Cards (Daily, Weekly, Monthly)
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard("Today's Revenue", dailyRevenue, Colors.orange[800]!),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildRevenueCard("This Week", weeklyRevenue, Colors.blue[800]!),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildRevenueCard("This Month", monthlyRevenue, Colors.purple[800]!),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Top Earning Item Banner Today
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD95325).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD95325).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department, color: Color(0xFFD95325)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Top Earning Item Today",
                              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topEarningItemToday,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            if (maxItemRevenueToday > 0)
                              Text(
                                "Generated Rs. ${maxItemRevenueToday.toStringAsFixed(0)} today",
                                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Earnings Itemized Receipt Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daily Itemized Receipt",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(now),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                dailyItemBreakdown.isEmpty
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "No completed orders or items sold yet today.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dailyItemBreakdown.keys.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, index) {
                      String itemName = dailyItemBreakdown.keys.elementAt(index);
                      var itemData = dailyItemBreakdown[itemName]!;
                      int qty = itemData['qty'];
                      double rev = itemData['revenue'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Quantity sold: $qty",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "Rs. ${rev.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFFD95325),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            "Rs. ${amount.toStringAsFixed(0)}",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}