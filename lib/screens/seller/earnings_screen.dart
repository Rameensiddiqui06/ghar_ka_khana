// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EarningsScreen extends StatelessWidget {
//   const EarningsScreen({super.key});

//   static const _months = [
//     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//   ];

//   String _dateLabel(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

//   @override
//   Widget build(BuildContext context) {
//     final String? uid = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F6F0),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Earnings & Analytics",
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: uid == null
//           ? const Center(child: Text('Please log in again.'))
//           : StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('orders')
//                   .where('sellerId', isEqualTo: uid)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   debugPrint('Earnings error: ${snapshot.error}');
//                   return Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Text(
//                         'Could not load earnings.\n${snapshot.error}',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ),
//                   );
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.account_balance_wallet_outlined,
//                             size: 64, color: Colors.grey[400]),
//                         const SizedBox(height: 12),
//                         Text(
//                           "No earnings data yet.",
//                           style:
//                               TextStyle(fontSize: 16, color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final now = DateTime.now();
//                 double dailyRevenue = 0;
//                 double weeklyRevenue = 0;
//                 double monthlyRevenue = 0;

//                 final Map<String, Map<String, num>> dailyItemBreakdown = {};
//                 String topEarningItemToday = 'No sales today';
//                 double maxItemRevenueToday = 0;

//                 for (final doc in snapshot.data!.docs) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final double total = ((data['total'] ?? 0) as num).toDouble();
//                   final String status = (data['status'] ?? 'pending').toString();

//                   // Only delivered orders count as revenue
//                   if (status != 'delivered') continue;

//                   final raw = data['createdAt'];
//                   final DateTime orderDate =
//                       raw is Timestamp ? raw.toDate() : now;

//                   final bool isToday = orderDate.year == now.year &&
//                       orderDate.month == now.month &&
//                       orderDate.day == now.day;

//                   if (isToday) {
//                     dailyRevenue += total;
//                     final List items = data['items'] ?? [];
//                     for (final item in items) {
//                       final String name =
//                           (item['name'] ?? 'Unknown Dish').toString();
//                       final int qty = ((item['qty'] ?? 1) as num).toInt();
//                       final double price =
//                           ((item['price'] ?? 0) as num).toDouble();
//                       final entry = dailyItemBreakdown.putIfAbsent(
//                         name,
//                         () => {'qty': 0, 'revenue': 0.0},
//                       );
//                       entry['qty'] = (entry['qty'] ?? 0) + qty;
//                       entry['revenue'] = (entry['revenue'] ?? 0) + price * qty;
//                     }
//                   }

//                   if (now.difference(orderDate).inDays <= 7) {
//                     weeklyRevenue += total;
//                   }
//                   if (orderDate.year == now.year &&
//                       orderDate.month == now.month) {
//                     monthlyRevenue += total;
//                   }
//                 }

//                 dailyItemBreakdown.forEach((name, details) {
//                   final rev = (details['revenue'] ?? 0).toDouble();
//                   if (rev > maxItemRevenueToday) {
//                     maxItemRevenueToday = rev;
//                     topEarningItemToday = name;
//                   }
//                 });

//                 final names = dailyItemBreakdown.keys.toList();

//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _revenueCard("Today's Revenue",
//                                 dailyRevenue, Colors.orange[800]!),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _revenueCard(
//                                 "This Week", weeklyRevenue, Colors.blue[800]!),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _revenueCard("This Month", monthlyRevenue,
//                                 Colors.purple[800]!),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color:
//                                 const Color(0xFFD95325).withValues(alpha: 0.3),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFD95325)
//                                     .withValues(alpha: 0.1),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.local_fire_department,
//                                 color: Color(0xFFD95325),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Top Earning Item Today",
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     topEarningItemToday,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   if (maxItemRevenueToday > 0)
//                                     Text(
//                                       "Generated Rs. ${maxItemRevenueToday.toStringAsFixed(0)} today",
//                                       style: const TextStyle(
//                                         color: Colors.green,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Daily Itemized Receipt",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           Text(
//                             _dateLabel(now),
//                             style: TextStyle(
//                                 color: Colors.grey[600], fontSize: 13),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       names.isEmpty
//                           ? Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(24),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   "No delivered orders or items sold yet today.",
//                                   style: TextStyle(
//                                       color: Colors.grey, fontSize: 13),
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color:
//                                         Colors.black.withValues(alpha: 0.02),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: names.length,
//                                 separatorBuilder: (_, __) => const Divider(
//                                   height: 1,
//                                   color: Colors.grey,
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   final name = names[index];
//                                   final d = dailyItemBreakdown[name]!;
//                                   final int qty = (d['qty'] ?? 0).toInt();
//                                   final double rev =
//                                       (d['revenue'] ?? 0).toDouble();
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 name,
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 "Quantity sold: $qty",
//                                                 style: TextStyle(
//                                                   color: Colors.grey[600],
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Text(
//                                           "Rs. ${rev.toStringAsFixed(0)}",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 15,
//                                             color: Color(0xFFD95325),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   Widget _revenueCard(String title, double amount, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Rs. ${amount.toStringAsFixed(0)}",
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/order.dart';

/// Seller earnings & analytics.
///
/// Revenue only counts orders whose status is `delivered`.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  static const Color _brand = Color(0xFFD95325);
  static const Color _pageBg = Color(0xFFF9F6F0);

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  late DateTime _selectedDay;
  int _rangeDays = 7;

  @override
  void initState() {
    super.initState();
    _selectedDay = _dayOnly(DateTime.now());
    if (_uid != null) {
      _stream = FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: _uid)
          .snapshots();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  String _shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  String _timeLabel(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  String _hourLabel(int h) {
    if (h == 0) return '12a';
    if (h < 12) return '${h}a';
    if (h == 12) return '12p';
    return '${h - 12}p';
  }

  String _fmt(num v) => v.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  String _rs(num v) => 'Rs. ${_fmt(v)}';

  String _compact(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}k';
    }
    return v.toInt().toString();
  }

  String _methodName(String m) {
    switch (m) {
      case 'easypaisa':
        return 'Easypaisa';
      case 'jazzcash':
        return 'JazzCash';
      default:
        return 'Cash on Delivery';
    }
  }

  Color _methodColor(String m) {
    switch (m) {
      case 'easypaisa':
        return AppColors.success;
      case 'jazzcash':
        return AppColors.error;
      default:
        return AppColors.warn;
    }
  }

  double _niceInterval(double maxVal) {
    if (maxVal <= 0) return 250;
    final raw = maxVal / 4;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final n = raw / mag;
    final nice = n <= 1 ? 1.0 : (n <= 2 ? 2.0 : (n <= 5 ? 5.0 : 10.0));
    return nice * mag;
  }

  double _niceMax(double maxVal, double interval) {
    if (maxVal <= 0) return interval * 4;
    return interval * (maxVal / interval).ceil();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Earnings & Analytics',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _uid == null || _stream == null
          ? const Center(child: Text('Please log in again.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Earnings error: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load earnings.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = <FoodOrder>[];
                for (final doc in snapshot.data?.docs ?? const []) {
                  try {
                    orders.add(FoodOrder.fromMap(doc.id, doc.data()));
                  } catch (e) {
                    debugPrint('Skipping bad order ${doc.id}: $e');
                  }
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No earnings data yet.',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return _content(orders);
              },
            ),
    );
  }

  Widget _content(List<FoodOrder> orders) {
    final today = _dayOnly(DateTime.now());
    final weekStart = DateTime(today.year, today.month, today.day - 6);
    final monthStart = DateTime(today.year, today.month, 1);

    final delivered = orders.where((o) => o.status == 'delivered').toList();

    // ---- Totals --------------------------------------------------------------
    int todayRev = 0, weekRev = 0, monthRev = 0;
    int todayCnt = 0, weekCnt = 0, monthCnt = 0;

    final dayRevenue = <DateTime, int>{};
    final hourCounts = List<int>.filled(24, 0);
    final methodTotals = <String, int>{};
    final dishStats = <String, _DishStat>{};

    for (final o in delivered) {
      final day = _dayOnly(o.createdAt);
      dayRevenue[day] = (dayRevenue[day] ?? 0) + o.total;

      if (day == today) {
        todayRev += o.total;
        todayCnt++;
      }
      if (!day.isBefore(weekStart)) {
        weekRev += o.total;
        weekCnt++;
      }
      if (!day.isBefore(monthStart)) {
        monthRev += o.total;
        monthCnt++;
        hourCounts[o.createdAt.hour]++;
        methodTotals[o.paymentMethod] =
            (methodTotals[o.paymentMethod] ?? 0) + o.total;
        for (final i in o.items) {
          final s = dishStats.putIfAbsent(i.name, () => _DishStat());
          s.qty += i.qty;
          s.revenue += i.price * i.qty;
        }
      }
    }

    final avgOrder = monthCnt == 0 ? 0 : (monthRev / monthCnt);
    final awaitingVerification = orders
        .where((o) =>
            o.paymentStatus == 'awaiting-verification' &&
            o.status != 'cancelled')
        .length;

    // ---- Selected day (receipt) ---------------------------------------------
    final dayOrders = delivered
        .where((o) => _sameDay(o.createdAt, _selectedDay))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final dayItems = <String, _DishStat>{};
    int daySubtotal = 0, dayDelivery = 0, dayTotal = 0, dayQty = 0;
    int dayAwaiting = 0;
    final dayMethods = <String, int>{};
    for (final o in dayOrders) {
      daySubtotal += o.subtotal;
      dayDelivery += o.delivery;
      dayTotal += o.total;
      dayMethods[o.paymentMethod] =
          (dayMethods[o.paymentMethod] ?? 0) + o.total;
      if (o.paymentStatus == 'awaiting-verification') dayAwaiting++;
      for (final i in o.items) {
        final s = dayItems.putIfAbsent(i.name, () => _DishStat());
        s.qty += i.qty;
        s.revenue += i.price * i.qty;
        dayQty += i.qty;
      }
    }
    final dayItemNames = dayItems.keys.toList()
      ..sort((a, b) => dayItems[b]!.revenue.compareTo(dayItems[a]!.revenue));

    final dayOther = orders.where((o) {
      return _sameDay(o.createdAt, _selectedDay) &&
          o.status != 'delivered' &&
          o.status != 'cancelled';
    }).length;
    final dayCancelled = orders
        .where((o) =>
            _sameDay(o.createdAt, _selectedDay) && o.status == 'cancelled')
        .length;

    // ---- Chart series --------------------------------------------------------
    final series = List<_DayRev>.generate(_rangeDays, (i) {
      final d = DateTime(today.year, today.month, today.day - (_rangeDays - 1 - i));
      return _DayRev(d, dayRevenue[d] ?? 0);
    });

    final topDishes = dishStats.entries.toList()
      ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Revenue cards ----
              Row(
                children: [
                  Expanded(
                    child: _revenueCard("Today's Revenue", todayRev, todayCnt,
                        Colors.orange[800]!),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _revenueCard(
                        'Last 7 Days', weekRev, weekCnt, Colors.blue[800]!),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _revenueCard(
                        'This Month', monthRev, monthCnt, Colors.purple[800]!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statTile(
                      Icons.receipt_long_outlined,
                      'Avg. order (month)',
                      _rs(avgOrder),
                      AppColors.text2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statTile(
                      Icons.shopping_bag_outlined,
                      'Delivered (month)',
                      '$monthCnt',
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statTile(
                      Icons.hourglass_bottom_rounded,
                      'Payments to verify',
                      '$awaitingVerification',
                      awaitingVerification > 0
                          ? AppColors.warn
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- Revenue trend ----
              _revenueTrendCard(series),
              const SizedBox(height: 16),

              // ---- Top earning item (selected day) ----
              _topItemCard(dayItemNames, dayItems),
              const SizedBox(height: 16),

              // ---- Top dishes this month ----
              _topDishesCard(topDishes),
              const SizedBox(height: 16),

              // ---- Payment split ----
              _paymentSplitCard(methodTotals, monthRev),
              const SizedBox(height: 16),

              // ---- Busiest hours ----
              _busyHoursCard(hourCounts),
              const SizedBox(height: 24),

              // ---- Daily itemized receipt ----
              _receiptSection(
                dayOrders: dayOrders,
                dayItems: dayItems,
                dayItemNames: dayItemNames,
                daySubtotal: daySubtotal,
                dayDelivery: dayDelivery,
                dayTotal: dayTotal,
                dayQty: dayQty,
                dayMethods: dayMethods,
                dayAwaiting: dayAwaiting,
                dayOther: dayOther,
                dayCancelled: dayCancelled,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Small widgets
  // ---------------------------------------------------------------------------

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  Widget _revenueCard(String title, int amount, int orders, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _rs(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$orders order${orders == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _emptyNote(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
      );

  // ---------------------------------------------------------------------------
  // Revenue trend chart (7 days = bars, 30 days = line)
  // ---------------------------------------------------------------------------

  Widget _revenueTrendCard(List<_DayRev> series) {
    final total = series.fold<int>(0, (s, d) => s + d.revenue);
    final maxVal =
        series.fold<double>(0, (m, d) => math.max(m, d.revenue.toDouble()));
    final interval = _niceInterval(maxVal);
    final maxY = _niceMax(maxVal, interval);

    final leftTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: interval,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            _compact(value),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ),
      ),
    );
    const noTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));
    final grid = FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (v) =>
          const FlLine(color: AppColors.sand, strokeWidth: 1),
    );

    Widget chart;
    if (total == 0) {
      chart = _emptyNote('No delivered orders in the last $_rangeDays days.');
    } else if (_rangeDays <= 7) {
      chart = BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: maxY,
          gridData: grid,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: noTitles,
            rightTitles: noTitles,
            leftTitles: leftTitles,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= series.length) {
                    return const SizedBox.shrink();
                  }
                  final isToday = i == series.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      isToday ? 'Today' : _weekdays[series[i].day.weekday - 1],
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isToday ? _brand : AppColors.muted,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = series[group.x];
                return BarTooltipItem(
                  '${_shortDate(d.day)}\n${_rs(d.revenue)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < series.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: series[i].revenue.toDouble(),
                    width: 20,
                    color: i == series.length - 1
                        ? _brand
                        : _brand.withValues(alpha: 0.55),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      );
    } else {
      chart = LineChart(
        LineChartData(
          minX: 0,
          maxX: (series.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: grid,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: noTitles,
            rightTitles: noTitles,
            leftTitles: leftTitles,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= series.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _shortDate(series[i].day),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final d = series[s.x.round().clamp(0, series.length - 1)];
                return LineTooltipItem(
                  '${_shortDate(d.day)}\n${_rs(d.revenue)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < series.length; i++)
                  FlSpot(i.toDouble(), series[i].revenue.toDouble()),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              color: _brand,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _brand.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      );
    }

    return _sectionCard(
      title: 'Revenue trend',
      subtitle: '${_rs(total)} in the last $_rangeDays days',
      trailing: SegmentedButton<int>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: const [
          ButtonSegment(value: 7, label: Text('7 days')),
          ButtonSegment(value: 30, label: Text('30 days')),
        ],
        selected: {_rangeDays},
        onSelectionChanged: (s) => setState(() => _rangeDays = s.first),
      ),
      child: SizedBox(height: 220, child: chart),
    );
  }

  // ---------------------------------------------------------------------------
  // Top earning item (for selected day)
  // ---------------------------------------------------------------------------

  Widget _topItemCard(List<String> names, Map<String, _DishStat> items) {
    final isToday = _sameDay(_selectedDay, DateTime.now());
    final String title = names.isEmpty ? 'No sales' : names.first;
    final int rev = names.isEmpty ? 0 : items[names.first]!.revenue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _brand.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _brand.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: _brand),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? 'Top Earning Item Today'
                      : 'Top Earning Item · ${_shortDate(_selectedDay)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (rev > 0)
                  Text(
                    'Generated ${_rs(rev)} · ${items[names.first]!.qty} sold',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top dishes this month
  // ---------------------------------------------------------------------------

  Widget _topDishesCard(List<MapEntry<String, _DishStat>> dishes) {
    final top = dishes.take(5).toList();
    final maxRev = top.isEmpty ? 1 : math.max(1, top.first.value.revenue);

    return _sectionCard(
      title: 'Best-selling dishes',
      subtitle: 'This month, by revenue',
      child: top.isEmpty
          ? _emptyNote('No delivered orders this month yet.')
          : Column(
              children: [
                for (var i = 0; i < top.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == top.length - 1 ? 0 : 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == 0
                                    ? _brand
                                    : _brand.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: i == 0 ? Colors.white : _brand,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                top[i].key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Text(
                              '${top[i].value.qty} sold · ${_rs(top[i].value.revenue)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: top[i].value.revenue / maxRev,
                            minHeight: 8,
                            backgroundColor: AppColors.sand,
                            valueColor: AlwaysStoppedAnimation(
                              i == 0 ? _brand : _brand.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment split donut
  // ---------------------------------------------------------------------------

  Widget _paymentSplitCard(Map<String, int> totals, int monthRev) {
    final entries = totals.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _sectionCard(
      title: 'Payment methods',
      subtitle: 'This month, delivered orders',
      child: entries.isEmpty
          ? _emptyNote('No delivered orders this month yet.')
          : Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 42,
                      sections: [
                        for (final e in entries)
                          PieChartSectionData(
                            value: e.value.toDouble(),
                            color: _methodColor(e.key),
                            radius: 38,
                            title: '${(e.value * 100 / monthRev).round()}%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _methodColor(e.key),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _methodName(e.key),
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.text),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _rs(e.value),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Busiest hours
  // ---------------------------------------------------------------------------

  Widget _busyHoursCard(List<int> counts) {
    final maxCount = counts.fold<int>(0, math.max);
    final peak = maxCount == 0 ? -1 : counts.indexOf(maxCount);
    final interval = math.max(1, (maxCount / 4).ceil()).toDouble();
    final maxY = math.max(interval * 4, maxCount.toDouble());

    const noTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));

    return _sectionCard(
      title: 'Busiest hours',
      subtitle: peak < 0
          ? 'Delivered orders by hour, this month'
          : 'Peak: ${_hourLabel(peak).replaceAll('a', ' AM').replaceAll('p', ' PM')} '
              '($maxCount order${maxCount == 1 ? '' : 's'})',
      child: maxCount == 0
          ? _emptyNote('No delivered orders this month yet.')
          : SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (v) =>
                        const FlLine(color: AppColors.sand, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: noTitles,
                    rightTitles: noTitles,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.muted),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final h = value.toInt();
                          if (h % 3 != 0 || h < 0 || h > 23) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _hourLabel(h),
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.muted),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final h = group.x;
                        final n = counts[h];
                        return BarTooltipItem(
                          '${_hourLabel(h)}\n$n order${n == 1 ? '' : 's'}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (var h = 0; h < 24; h++)
                      BarChartGroupData(
                        x: h,
                        barRods: [
                          BarChartRodData(
                            toY: counts[h].toDouble(),
                            width: 7,
                            color: h == peak
                                ? _brand
                                : _brand.withValues(alpha: 0.45),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Daily itemized receipt
  // ---------------------------------------------------------------------------

  Future<void> _pickDay() async {
    final today = _dayOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2024),
      lastDate: today,
    );
    if (picked != null) setState(() => _selectedDay = _dayOnly(picked));
  }

  void _shiftDay(int delta) {
    final today = _dayOnly(DateTime.now());
    final next = DateTime(
        _selectedDay.year, _selectedDay.month, _selectedDay.day + delta);
    if (next.isAfter(today)) return;
    setState(() => _selectedDay = next);
  }

  Widget _receiptSection({
    required List<FoodOrder> dayOrders,
    required Map<String, _DishStat> dayItems,
    required List<String> dayItemNames,
    required int daySubtotal,
    required int dayDelivery,
    required int dayTotal,
    required int dayQty,
    required Map<String, int> dayMethods,
    required int dayAwaiting,
    required int dayOther,
    required int dayCancelled,
  }) {
    final today = _dayOnly(DateTime.now());
    final isToday = _sameDay(_selectedDay, today);

    Widget headerCell(String t, {TextAlign align = TextAlign.left}) => Text(
          t,
          textAlign: align,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
          ),
        );

    Widget totalRow(String label, String value,
        {bool bold = false, Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: AppColors.text2,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: bold ? 17 : 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: color ?? AppColors.text,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + date controls
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daily Itemized Receipt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Previous day',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shiftDay(-1),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _pickDay,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sand),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: _brand),
                    const SizedBox(width: 6),
                    Text(
                      isToday ? 'Today' : _dateLabel(_selectedDay),
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next day',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_right),
              onPressed: isToday ? null : () => _shiftDay(1),
            ),
          ],
        ),
        Text(
          _dateLabel(_selectedDay),
          style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
        ),
        const SizedBox(height: 12),

        if (dayOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration,
            child: Center(
              child: Text(
                'No delivered orders on this day.'
                '${dayOther > 0 ? '\n$dayOther order${dayOther == 1 ? '' : 's'} still in progress.' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else ...[
          // Receipt card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: _brand, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${dayOrders.length} order${dayOrders.length == 1 ? '' : 's'}'
                        ' · $dayQty item${dayQty == 1 ? '' : 's'} sold',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Table header
                Row(
                  children: [
                    Expanded(child: headerCell('ITEM')),
                    SizedBox(
                        width: 34,
                        child: headerCell('QTY', align: TextAlign.center)),
                    SizedBox(
                        width: 66,
                        child: headerCell('PRICE', align: TextAlign.right)),
                    SizedBox(
                        width: 78,
                        child: headerCell('AMOUNT', align: TextAlign.right)),
                  ],
                ),
                const Divider(height: 16, color: AppColors.sand),

                for (final name in dayItemNames)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(dayItems[name]!.revenue * 100 / (daySubtotal == 0 ? 1 : daySubtotal)).round()}% of sales',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 34,
                          child: Text(
                            '${dayItems[name]!.qty}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(
                          width: 66,
                          child: Text(
                            _fmt(dayItems[name]!.revenue / dayItems[name]!.qty),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 12.5, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 78,
                          child: Text(
                            _fmt(dayItems[name]!.revenue),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: _brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 24, color: AppColors.sand),
                totalRow('Items subtotal', _rs(daySubtotal)),
                totalRow('Delivery fees', _rs(dayDelivery)),
                const SizedBox(height: 4),
                totalRow('Total revenue', _rs(dayTotal),
                    bold: true, color: _brand),

                const Divider(height: 28, color: AppColors.sand),
                const Text(
                  'Collected via',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 6),
                for (final e in dayMethods.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _methodColor(e.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _methodName(e.key),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          _rs(e.value),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                if (dayAwaiting > 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warn.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.warn),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$dayAwaiting online payment${dayAwaiting == 1 ? '' : 's'} '
                            'not verified yet. Check the TID in Orders and mark as paid.',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.text2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Orders of the day
          const Text(
            "Orders of the day",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: _cardDecoration,
            child: Column(
              children: [
                for (var i = 0; i < dayOrders.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.sand),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${dayOrders[i].id} · ${_timeLabel(dayOrders[i].createdAt)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                dayOrders[i]
                                    .items
                                    .map((e) => '${e.qty}× ${e.name}')
                                    .join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_methodName(dayOrders[i].paymentMethod)} · '
                                '${dayOrders[i].paymentStatusLabel}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _methodColor(
                                      dayOrders[i].paymentMethod),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _rs(dayOrders[i].total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        if (dayOther > 0 || dayCancelled > 0) ...[
          const SizedBox(height: 10),
          Text(
            [
              if (dayOther > 0)
                '$dayOther order${dayOther == 1 ? '' : 's'} not delivered yet (not counted)',
              if (dayCancelled > 0) '$dayCancelled cancelled',
            ].join(' · '),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}

class _DishStat {
  int qty = 0;
  int revenue = 0;
}

class _DayRev {
  final DateTime day;
  final int revenue;
  const _DayRev(this.day, this.revenue);
}