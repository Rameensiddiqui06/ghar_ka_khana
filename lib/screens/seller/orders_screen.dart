import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/status_pill.dart';

const _progressStatuses = {
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
  'pending': 'Accept order',
  'accepted': 'Start preparing',
  'preparing': 'Mark ready',
  'ready': 'Out for delivery',
  'out-for-delivery': 'Mark delivered',
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
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Incoming Orders',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.muted,
                    indicatorColor: AppColors.primary,
                    dividerColor: AppColors.sand,
                    tabs: [
                      Tab(text: 'New'),
                      Tab(text: 'In progress'),
                      Tab(text: 'Done'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: uid == null
                  ? const Center(
                      child: Text(
                        'Please log in again',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : StreamBuilder<List<FoodOrder>>(
                      stream: OrderService().streamSellerOrders(uid),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          debugPrint('Seller orders error: ${snap.error}');
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Could not load orders.\n${snap.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          );
                        }
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final all = snap.data!;
                        final fresh =
                            all.where((o) => o.status == 'pending').toList();
                        final progress = all
                            .where((o) => _progressStatuses.contains(o.status))
                            .toList();
                        final done = all
                            .where(
                              (o) =>
                                  o.status == 'delivered' ||
                                  o.status == 'cancelled',
                            )
                            .toList();
                        return TabBarView(
                          children: [
                            _SellerOrderList(
                              orders: fresh,
                              emptyText: 'No new orders',
                            ),
                            _SellerOrderList(
                              orders: progress,
                              emptyText: 'Nothing in progress',
                            ),
                            _SellerOrderList(
                              orders: done,
                              emptyText: 'No completed orders yet',
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

class _SellerOrderList extends StatelessWidget {
  final List<FoodOrder> orders;
  final String emptyText;
  const _SellerOrderList({required this.orders, required this.emptyText});

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
      itemBuilder: (_, i) => _SellerOrderCard(order: orders[i]),
    );
  }
}

class _SellerOrderCard extends StatefulWidget {
  final FoodOrder order;
  const _SellerOrderCard({required this.order});

  @override
  State<_SellerOrderCard> createState() => _SellerOrderCardState();
}

class _SellerOrderCardState extends State<_SellerOrderCard> {
  final _service = OrderService();
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (e) {
      debugPrint('Seller order action failed: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not update the order. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _line(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            l,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(fontSize: 13, color: AppColors.text),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final next = _nextStatus[o.status];
    final canCancel = o.status == 'pending' || o.status == 'accepted';
    final needsVerify = o.paymentStatus == 'awaiting-verification';

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
                '#${o.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              StatusPill(status: o.status),
            ],
          ),
          const SizedBox(height: 10),
          for (final i in o.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${i.name} × ${i.qty}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Rs. ${i.price * i.qty}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 20, color: AppColors.sand),
          _line('Address', o.address),
          if (o.phone.isNotEmpty) _line('Phone', o.phone),
          if (o.notes.isNotEmpty) _line('Notes', o.notes),
          _line('Payment', '${o.payment} · ${o.paymentStatusLabel}'),
          if (o.transactionId.isNotEmpty) _line('TID', o.transactionId),
          const SizedBox(height: 8),
          Text(
            'Total Rs. ${o.total}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          if (needsVerify && o.status != 'cancelled') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _run(() => _service.markPaid(o.id)),
                child: const Text('Payment received (TID verified)'),
              ),
            ),
          ],
          if (next != null || canCancel) const SizedBox(height: 12),
          Row(
            children: [
              if (canCancel)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => _service.updateStatus(o.id, 'cancelled'),
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              if (canCancel && next != null) const SizedBox(width: 10),
              if (next != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() async {
                            await _service.updateStatus(o.id, next);
                            if (next == 'delivered' &&
                                o.paymentMethod == 'cod') {
                              await _service.markPaid(o.id);
                            }
                          }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_nextLabel[o.status] ?? 'Next'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}