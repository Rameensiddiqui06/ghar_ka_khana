import 'package:flutter/material.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardTab(),
            _buildPlaceholderTab('Orders Screen', Icons.inventory_2_outlined),
            _buildPlaceholderTab('Today\'s Menu Screen', Icons.restaurant_menu),
            _buildPlaceholderTab('Earnings Screen', Icons.account_balance_wallet_outlined),
            _buildPlaceholderTab('Profile & Notifications', Icons.person_outline),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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

  // --- Main Dashboard View ---
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildOverviewGrid(),
          const SizedBox(height: 20),
          _buildRevenueChartCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildTodaysOrdersHeader(),
          const SizedBox(height: 12),
          _buildOrderCard(
            orderId: '#GK12346',
            customerName: 'Zara Malik',
            time: '6:40 PM',
            items: 'Chicken Biryani ×2, Gulab Jamun ×1',
            price: 'Rs. 1100',
            status: 'New',
            statusColor: const Color(0xFFFFF2E2),
            statusTextColor: const Color(0xFFE07A5F),
            showAcceptReject: true,
          ),
          const SizedBox(height: 12),
          _buildOrderCard(
            orderId: '#GK12345',
            customerName: 'Ayesha Khan',
            time: '6:15 PM',
            items: 'Chicken Karahi ×1',
            price: 'Rs. 650',
            status: 'Preparing',
            statusColor: const Color(0xFFFFF2E2),
            statusTextColor: const Color(0xFFE07A5F),
            showMarkReady: true,
          ),
          const SizedBox(height: 24),
          Text(
            "Popular Items",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[900],
            ),
          ),
          const SizedBox(height: 12),
          _buildPopularItem('#1', 'Chicken Biryani', 'Rs. 450', '4.8'),
          _buildPopularItem('#2', 'Chicken Karahi', 'Rs. 650', '4.9'),
          _buildPopularItem('#3', 'Gulab Jamun', 'Rs. 200', '4.8'),
        ],
      ),
    );
  }

  // --- Placeholder for other tabs ---
  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFC05638)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown[900],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Full feature coming in next sprint!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- UI Elements ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              "Good morning, Ammi's Kitc...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown[900],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    "Verified Seller • Open Now",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
  }

  Widget _buildOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard("12", "Today's Orders", Icons.card_giftcard, Colors.orange, () => setState(() => _selectedIndex = 1)),
        _buildStatCard("Rs. 8,450", "Today's Sales", Icons.attach_money, Colors.green, () => setState(() => _selectedIndex = 3)),
        _buildStatCard("4", "Pending", Icons.hourglass_top, Colors.amber, () => setState(() => _selectedIndex = 1)),
        _buildStatCard("18", "Today's Menu", Icons.restaurant, Colors.purple, () => setState(() => _selectedIndex = 2)),
      ],
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color, VoidCallback onTap) {
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
              color: Colors.black.withOpacity(0.03),
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
                color: color == Colors.green ? Colors.teal[700] : Colors.brown[900],
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard() {
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
                "Revenue This Week",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
              const Text(
                "+18%",
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar("M", 40),
              _buildBar("T", 65),
              _buildBar("W", 45),
              _buildBar("T", 80),
              _buildBar("F", 70),
              _buildBar("S", 90),
              _buildBar("S", 100, isHighlight: true),
            ],
          )
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
        Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
            _buildActionItem(Icons.add, "Add Food", Colors.purple, () => _showSnackBar('Opening Add Food screen...')),
            _buildActionItem(Icons.inventory_2_outlined, "Orders", Colors.orange, () => setState(() => _selectedIndex = 1)),
            _buildActionItem(Icons.circle, "Availability", Colors.green, () => _showSnackBar('Kitchen Status: Open')),
            _buildActionItem(Icons.bar_chart, "Earnings", Colors.blue, () => setState(() => _selectedIndex = 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTodaysOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today's Orders",
          style: TextStyle(
            fontSize: 18,
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

  Widget _buildOrderCard({
    required String orderId,
    required String customerName,
    required String time,
    required String items,
    required String price,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    bool showAcceptReject = false,
    bool showMarkReady = false,
  }) {
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
                orderId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown[900],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            "$customerName • $time",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(items, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFC05638),
                ),
              ),
              if (showAcceptReject)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showSnackBar('Order $orderId Accepted!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F5E9),
                        elevation: 0,
                      ),
                      child: const Text("Accept", style: TextStyle(color: Colors.green)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showSnackBar('Order $orderId Rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        elevation: 0,
                      ),
                      child: const Text("Reject", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              if (showMarkReady)
                ElevatedButton(
                  onPressed: () => _showSnackBar('Order $orderId marked as Ready!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF2E2),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Mark Ready",
                    style: TextStyle(color: Color(0xFFC05638)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItem(String rank, String title, String price, String rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                ),
                Text(
                  "$price • ★ $rating",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            rank,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC05638),
            ),
          ),
        ],
      ),
    );
  }
}