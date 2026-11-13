import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../models/seller.dart';
import '../../services/cart_controller.dart';
import '../../services/food_service.dart';
import '../../services/order_service.dart';
import '../../widgets/primary_button.dart';
import 'order_success_screen.dart';

enum PayMethod { cod, easypaisa, jazzcash }

class CheckoutScreen extends StatefulWidget {
  final CartController cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _foodService = FoodService();
  final _orderService = OrderService();

  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final Map<String, TextEditingController> _tids = {};

  Map<String, Seller> _sellers = {};
  PayMethod _method = PayMethod.cod;
  bool _loading = true;
  bool _placing = false;

  Map<String, List<CartItem>> get _groups {
    final g = <String, List<CartItem>>{};
    for (final i in widget.cart.items) {
      g.putIfAbsent(i.food.sellerId, () => []).add(i);
    }
    return g;
  }

  @override
  void initState() {
    super.initState();
    for (final id in _groups.keys) {
      _tids[id] = TextEditingController();
    }
    _loadSellers();
  }

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    _notes.dispose();
    for (final c in _tids.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSellers() async {
    try {
      final results = await Future.wait(
        _groups.keys.map((id) => _foodService.getSellerById(id)),
      );
      final map = <String, Seller>{};
      for (final s in results) {
        if (s != null) map[s.id] = s;
      }
      if (!mounted) return;
      setState(() {
        _sellers = map;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Could not load sellers for checkout: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  String _numberFor(Seller? s, PayMethod m) {
    if (s == null) return '';
    if (m == PayMethod.easypaisa) return s.easypaisaNumber;
    if (m == PayMethod.jazzcash) return s.jazzcashNumber;
    return '';
  }

  bool _available(PayMethod m) {
    if (m == PayMethod.cod) return true;
    return _groups.keys.every((id) => _numberFor(_sellers[id], m).isNotEmpty);
  }

  int _sellerTotal(List<CartItem> list) =>
      list.fold<int>(0, (s, i) => s + i.food.price * i.qty) +
      CartController.deliveryFeePerSeller;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _place() async {
    if (_placing) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Please log in again to place your order.');
      return;
    }

    final address = _address.text.trim();
    final phone = _phone.text.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (address.length < 10) {
      _snack('Please enter your full delivery address.');
      return;
    }
    if (!RegExp(r'^(03\d{9}|\+923\d{9})$').hasMatch(phone)) {
      _snack('Enter a valid mobile number, e.g. 03001234567.');
      return;
    }

    final tids = <String, String>{};
    if (_method != PayMethod.cod) {
      for (final id in _groups.keys) {
        final t = _tids[id]!.text.trim();
        if (t.length < 6) {
          final name = _groups[id]!.first.food.sellerName;
          _snack('Enter the transaction ID (TID) for $name.');
          return;
        }
        tids[id] = t;
      }
    }

    setState(() => _placing = true);
    try {
      final ids = await _orderService.placeOrders(
        customerId: user.uid,
        items: widget.cart.items,
        address: address,
        phone: phone,
        notes: _notes.text.trim(),
        method: _method.name,
        transactionIds: tids,
      );
      final total = widget.cart.total;
      widget.cart.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderIds: ids,
            total: total,
            methodLabel: OrderService.methodLabel(_method.name),
            isOnline: _method != PayMethod.cod,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Place order failed: $e');
      if (mounted) {
        _snack('Could not place order. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _card('Delivery details', _deliveryForm()),
                        const SizedBox(height: 14),
                        _card('Payment method', _paymentMethods()),
                        if (_method != PayMethod.cod) ...[
                          const SizedBox(height: 14),
                          ..._sellerPayCards(),
                        ],
                        const SizedBox(height: 14),
                        _summary(cart),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.sand)),
              ),
              child: PrimaryButton(
                text: _placing
                    ? 'Placing order…'
                    : 'Place Order · Rs. ${cart.total}',
                onPressed: _place,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
          ),
          const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _dec(String label, String hint) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: b(AppColors.sand),
      enabledBorder: b(AppColors.sand),
      focusedBorder: b(AppColors.primary),
    );
  }

  Widget _deliveryForm() {
    return Column(
      children: [
        TextField(
          controller: _address,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _dec(
            'Delivery address',
            'House/flat, street, area, Karachi',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: _dec('Mobile number', '03001234567'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _dec(
            'Notes for the seller (optional)',
            'Less spicy, call at the gate…',
          ),
        ),
      ],
    );
  }

  Widget _paymentMethods() {
    return Column(
      children: [
        _methodTile(
          PayMethod.cod,
          '💵',
          'Cash on Delivery',
          'Pay the rider when your food arrives',
        ),
        const SizedBox(height: 10),
        _methodTile(
          PayMethod.easypaisa,
          '📱',
          'Easypaisa',
          'Send money to the seller, then enter the TID',
        ),
        const SizedBox(height: 10),
        _methodTile(
          PayMethod.jazzcash,
          '📲',
          'JazzCash',
          'Send money to the seller, then enter the TID',
        ),
      ],
    );
  }

  Widget _methodTile(PayMethod m, String icon, String title, String sub) {
    final enabled = _available(m);
    final selected = _method == m;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? () => setState(() => _method = m) : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.sand,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? sub
                          : 'Not available for every seller in your cart',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sellerPayCards() {
    final label = OrderService.methodLabel(_method.name);
    final widgets = <Widget>[];
    for (final entry in _groups.entries) {
      final seller = _sellers[entry.key];
      final number = _numberFor(seller, _method);
      final amount = _sellerTotal(entry.value);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _card(
            'Pay ${entry.value.first.food.sellerName}',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Rs. $amount via $label to:',
                  style: const TextStyle(fontSize: 13, color: AppColors.text2),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.sand),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              number,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            if (seller != null &&
                                seller.accountTitle.isNotEmpty)
                              Text(
                                seller.accountTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy number',
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: number));
                          if (mounted) _snack('Number copied');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tids[entry.key],
                  textCapitalization: TextCapitalization.characters,
                  decoration: _dec(
                    'Transaction ID (TID)',
                    'From your payment confirmation SMS',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'The seller checks this TID and confirms your payment before preparing your order.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _summary(CartController cart) {
    Widget row(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: const TextStyle(fontSize: 14, color: AppColors.text2)),
          Text(v, style: const TextStyle(fontSize: 14, color: AppColors.text)),
        ],
      ),
    );
    return _card(
      'Order summary',
      Column(
        children: [
          row('Subtotal', 'Rs. ${cart.subtotal}'),
          row(
            'Delivery (${cart.sellerCount} seller'
                '${cart.sellerCount == 1 ? '' : 's'})',
            'Rs. ${cart.deliveryFee}',
          ),
          const Divider(height: 20, color: AppColors.sand),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                'Rs. ${cart.total}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
