import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'seller/profile_screen.dart';
import 'seller/manage_menu_screen.dart';
import 'seller/orders_screen.dart';
import 'seller/earnings_screen.dart';

const _activeStatuses = {
  'pending',
  'accepted',
  'preparing',
  'ready',
  'out-for-delivery',
};

const _nextStatus = {
  'pending': 'accepted',
  'accepted': 'preparing',
  'preparing': 'ready',
  'ready': 'out-for-delivery',
  'out-for-delivery': 'delivered',
};

const _nextLabel = {
  'pending': 'Accept',
  'accepted': 'Start Preparing',
  'preparing': 'Mark Ready',
  'ready': 'Out for Delivery',
  'out-for-delivery': 'Delivered',
};

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _setStatus(DocumentReference ref, String status) async {
    try {
      await ref.update({'status': status});
    } catch (e) {
      debugPrint('Status update failed: $e');
      _showSnackBar('Could not update the order. Try again.');
    }
  }

  Future<void> _toggleKitchenStatus(
    bool currentStatus,
    String currentUserId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({'isOpen': !currentStatus});
      _showSnackBar(
        !currentStatus ? "Kitchen is now Open!" : "Kitchen is now Closed.",
      );
    } catch (e) {
      try {
        await FirebaseFirestore.instance
            .collection('kitchens')
            .doc(currentUserId)
            .update({'isOpen': !currentStatus});
        _showSnackBar(
          !currentStatus ? "Kitchen is now Open!" : "Kitchen is now Closed.",
        );
      } catch (err) {
        _showSnackBar("Could not update kitchen status.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildLiveDashboardTab(),
            const OrdersScreen(),
            const ManageMenuScreen(),
            const EarningsScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFC05638),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDashboardTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("No active seller logged in."));
    }
    final String currentUserId = user.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, orderSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('kitchens')
              .doc(currentUserId)
              .collection('menu')
              .snapshots(),
          builder: (context, menuSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (orderSnapshot.hasError) {
              debugPrint('Dashboard orders error: ${orderSnapshot.error}');
            }

            int todaysOrdersCount = 0;
            double todaysSales = 0;
            int pendingCount = 0;
            final List<QueryDocumentSnapshot> activeOrders = [];

            if (orderSnapshot.hasData) {
              final now = DateTime.now();
              for (final doc in orderSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? 'pending').toString();
                final double amount =
                    ((data['total'] ?? 0) as num).toDouble();

                if (_activeStatuses.contains(status)) {
                  pendingCount++;
                  activeOrders.add(doc);
                }

                final raw = data['createdAt'];
                final DateTime? orderDate =
                    raw is Timestamp ? raw.toDate() : null;

                if (orderDate != null &&
                    orderDate.year == now.year &&
                    orderDate.month == now.month &&
                    orderDate.day == now.day) {
                  todaysOrdersCount++;
                  if (status == 'delivered') {
                    todaysSales += amount;
                  }
                }
              }

              // Newest first
              activeOrders.sort((a, b) {
                final ta = (a.data() as Map<String, dynamic>)['createdAt'];
                final tb = (b.data() as Map<String, dynamic>)['createdAt'];
                final da = ta is Timestamp ? ta.toDate() : DateTime(2000);
                final db = tb is Timestamp ? tb.toDate() : DateTime(2000);
                return db.compareTo(da);
              });
            }

            final int menuCount =
                menuSnapshot.hasData ? menuSnapshot.data!.docs.length : 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(currentUserId),
                  const SizedBox(height: 20),
                  if (orderSnapshot.hasError) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Could not load orders: ${orderSnapshot.error}',
                        style: TextStyle(color: Colors.red[800], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildOverviewGrid(
                    todaysOrders: todaysOrdersCount.toString(),
                    todaysSales: "Rs. ${todaysSales.toStringAsFixed(0)}",
                    pending: pendingCount.toString(),
                    menuItemsCount: menuCount.toString(),
                  ),
                  const SizedBox(height: 20),
                  _buildRevenueChartCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildActiveOrdersHeader(),
                  const SizedBox(height: 12),
                  activeOrders.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "No active orders right now.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeOrders.length,
                          itemBuilder: (context, index) {
                            final doc = activeOrders[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final String orderId = doc.id;
                            final String customerName =
                                (data['phone'] ?? 'Customer').toString();
                            final double amount =
                                ((data['total'] ?? 0) as num).toDouble();
                            final String status =
                                (data['status'] ?? 'pending').toString();
                            final List items = data['items'] ?? [];

                            final String itemsSummary = items
                                .map((i) => "${i['name']} ×${i['qty']}")
                                .join(', ');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildLiveOrderCard(
                                docRef: doc.reference,
                                orderId: '#$orderId',
                                customerName: customerName,
                                items: itemsSummary,
                                price: 'Rs. ${amount.toStringAsFixed(0)}',
                                status: status,
                              ),
                            );
                          },
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(String currentUserId) {
    final hour = DateTime.now().hour;
    String greeting = "Good morning";
    if (hour >= 12 && hour < 17) {
      greeting = "Good afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good evening";
    } else if (hour >= 21 || hour < 4) {
      greeting = "Good night";
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isOpen = true;
        String kitchenName = "My Kitchen";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          isOpen = data?['isOpen'] ?? true;

          final kn = data?['kitchenName'];
          final nm = data?['name'];
          if (kn is String && kn.isNotEmpty) {
            kitchenName = kn;
          } else if (nm is String && nm.isNotEmpty) {
            kitchenName = "$nm's Kitchen";
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome back",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    "$greeting, $kitchenName",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _toggleKitchenStatus(isOpen, currentUserId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOpen ? const Color(0xFFE8F5E9) : Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOpen
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: isOpen ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen
                                ? "Verified Seller • Open Now"
                                : "Kitchen Closed (Tap to Open)",
                            style: TextStyle(
                              color:
                                  isOpen ? Colors.green[800] : Colors.red[800],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.swap_horiz,
                            size: 14,
                            color: isOpen ? Colors.green[800] : Colors.red[800],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 4),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewGrid({
    required String todaysOrders,
    required String todaysSales,
    required String pending,
    required String menuItemsCount,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(todaysOrders, "Today's Orders", Icons.card_giftcard,
            Colors.orange, () => setState(() => _selectedIndex = 1)),
        _buildStatCard(todaysSales, "Today's Sales", Icons.attach_money,
            Colors.green, () => setState(() => _selectedIndex = 3)),
        _buildStatCard(pending, "Pending", Icons.hourglass_top, Colors.amber,
            () => setState(() => _selectedIndex = 1)),
        _buildStatCard(menuItemsCount, "Total Menu", Icons.restaurant,
            Colors.purple, () => setState(() => _selectedIndex = 2)),
      ],
    );
  }

  Widget _buildStatCard(
    String val,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              val,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    color == Colors.green ? Colors.teal[700] : Colors.brown[900],
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    final int currentDayIndex = DateTime.now().weekday - 1;
    const List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Revenue Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
              const Text(
                "Live",
                style:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final bool isToday = (index == currentDayIndex);
              double height = 50.0 + (index * 7);
              if (isToday) height = 95;
              return _buildBar(days[index], height, isHighlight: isToday);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, {bool isHighlight = false}) {
    return Column(
      children: [
        Container(
          height: height,
          width: 24,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFFC05638) : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            color: isHighlight ? const Color(0xFFC05638) : Colors.grey,
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(Icons.add, "Add Food", Colors.purple,
                () => setState(() => _selectedIndex = 2)),
            _buildActionItem(Icons.inventory_2_outlined, "Orders",
                Colors.orange, () => setState(() => _selectedIndex = 1)),
            _buildActionItem(Icons.circle, "Availability", Colors.green,
                () => _showSnackBar('Tap the status badge above to open or close your kitchen')),
            _buildActionItem(Icons.bar_chart, "Earnings", Colors.blue,
                () => setState(() => _selectedIndex = 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 65,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Active Orders Requiring Action",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 1),
          child: const Text(
            "See all",
            style: TextStyle(
              color: Color(0xFFC05638),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveOrderCard({
    required DocumentReference docRef,
    required String orderId,
    required String customerName,
    required String items,
    required String price,
    required String status,
  }) {
    Color statusColor;
    Color statusTextColor;

    switch (status) {
      case 'pending':
        statusColor = Colors.blue[100]!;
        statusTextColor = Colors.blue[900]!;
        break;
      case 'accepted':
      case 'preparing':
        statusColor = Colors.orange[100]!;
        statusTextColor = Colors.orange[900]!;
        break;
      default:
        statusColor = Colors.purple[100]!;
        statusTextColor = Colors.purple[900]!;
    }

    final next = _nextStatus[status];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.brown[900],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            customerName,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            items,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFFC05638),
                ),
              ),
              Row(
                children: [
                  if (status == 'pending') ...[
                    OutlinedButton(
                      onPressed: () => _setStatus(docRef, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(60, 32),
                      ),
                      child: const Text(
                        "Reject",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (next != null)
                    ElevatedButton(
                      onPressed: () => _setStatus(docRef, next),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD95325),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(60, 32),
                      ),
                      child: Text(
                        _nextLabel[status] ?? 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}