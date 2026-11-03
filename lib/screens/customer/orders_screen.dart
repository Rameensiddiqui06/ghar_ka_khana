

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/status_pill.dart';

const _activeStatuses = {
  'pending',
  'accepted',
  'preparing',
  'ready',
  'out-for-delivery',
};

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'My Orders',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.sand, width: 1),
                      ),
                    ),
                    child: const TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.muted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: uid == null
                  ? const Center(
                      child: Text(
                        'Please log in to see your orders',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : StreamBuilder<List<FoodOrder>>(
                      stream: OrderService().streamCustomerOrders(uid),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          debugPrint('Orders stream error: ${snap.error}');
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Could not load your orders. Check your connection and Firestore rules.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          );
                        }
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final orders = snap.data!;
                        final active = orders
                            .where((o) => _activeStatuses.contains(o.status))
                            .toList();
                        final completed = orders
                            .where((o) => o.status == 'delivered')
                            .toList();
                        final cancelled = orders
                            .where((o) => o.status == 'cancelled')
                            .toList();
                        return TabBarView(
                          children: [
                            _OrderList(
                              orders: active,
                              emptyText: 'No active orders',
                            ),
                            _OrderList(
                              orders: completed,
                              emptyText: 'No completed orders yet',
                            ),
                            _OrderList(
                              orders: cancelled,
                              emptyText: 'No cancelled orders',
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<FoodOrder> orders;
  final String emptyText;

  const _OrderList({required this.orders, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(color: AppColors.muted, fontSize: 15),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final FoodOrder order;
  const _OrderCard({required this.order});

  String get _whenLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      order.createdAt.year,
      order.createdAt.month,
      order.createdAt.day,
    );
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  String get _itemsText =>
      order.items.map((i) => '${i.name} × ${i.qty}').join(', ');

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OrderDetailsSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                '#${order.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$_whenLabel · ${order.sellerName}',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Text(
            _itemsText,
            style: const TextStyle(fontSize: 13.5, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            '${order.payment} · ${order.paymentStatusLabel}',
            style: const TextStyle(fontSize: 12, color: AppColors.text2),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.sand),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${order.total}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () => _openDetails(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final FoodOrder order;
  const _OrderDetailsSheet({required this.order});

  Widget _line(String l, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(fontSize: 13, color: AppColors.text2)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? AppColors.primary : AppColors.text,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                StatusPill(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              order.sellerName,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            for (final i in order.items)
              _line('${i.name} × ${i.qty}', 'Rs. ${i.price * i.qty}'),
            const Divider(height: 20, color: AppColors.sand),
            _line('Subtotal', 'Rs. ${order.subtotal}'),
            _line('Delivery', 'Rs. ${order.delivery}'),
            _line('Total', 'Rs. ${order.total}', bold: true),
            const Divider(height: 20, color: AppColors.sand),
            _line('Payment', order.payment),
            _line('Payment status', order.paymentStatusLabel),
            if (order.transactionId.isNotEmpty)
              _line('TID', order.transactionId),
            _line('Address', order.address),
            if (order.phone.isNotEmpty) _line('Phone', order.phone),
            if (order.notes.isNotEmpty) _line('Notes', order.notes),
            if (order.status == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await OrderService().cancelOrder(order.id);
                      nav.pop();
                    } catch (e) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Could not cancel this order.'),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel order'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
