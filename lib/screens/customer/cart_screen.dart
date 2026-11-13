

import 'checkout_screen.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/color_utils.dart';
import '../../models/seller.dart';
import '../../services/cart_controller.dart';
import '../../services/food_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/qty_selector.dart';
import '../../widgets/safe_image.dart';

class CartScreen extends StatefulWidget {
  final CartController cart;
  final VoidCallback onBack;

  const CartScreen({super.key, required this.cart, required this.onBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _service = FoodService();
  Map<String, Seller> _sellers = {};

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  // Only used for seller avatars in the cart. Safe to fail silently.
  Future<void> _loadSellers() async {
    try {
      final sellers = await _service.getSellers();
      if (!mounted) return;
      setState(() => _sellers = {for (final s in sellers) s.id: s});
    } catch (e) {
      debugPrint('Could not load sellers for cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.cart,
          builder: (context, _) {
            final cart = widget.cart;
            return Column(
              children: [
                _header(cart),
                Expanded(child: cart.isEmpty ? _empty() : _content(cart)),
                if (!cart.isEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.sand)),
                    ),
                    child: PrimaryButton(
                      text: 'Proceed to Checkout · Rs. ${cart.total}',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(cart: widget.cart),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(CartController cart) {
    final n = cart.itemCount;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
          ),
          const Expanded(
            child: Text(
              'Your Cart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$n item${n == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('🛒', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add some homemade goodness',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _content(CartController cart) {
    // Group items by seller
    final groups = <String, List<CartItem>>{};
    for (final item in cart.items) {
      groups.putIfAbsent(item.food.sellerId, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in groups.entries) ...[
          _sellerHeader(entry.key, entry.value.first),
          const SizedBox(height: 10),
          ...entry.value.map(_itemCard),
          const SizedBox(height: 4),
        ],
        const SizedBox(height: 8),
        _summary(cart),
      ],
    );
  }

  Widget _sellerHeader(String sellerId, CartItem first) {
    final seller = _sellers[sellerId];
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SafeImage(
            imageUrl: seller?.avatarUrl,
            emoji: seller?.avatarEmoji ?? '👩‍🍳',
            bgColor: seller != null
                ? hexToColor(seller.avatarBgHex)
                : AppColors.sand,
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            first.food.sellerName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemCard(CartItem item) {
    final f = item.food;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SafeImage(
              imageUrl: f.imageUrl,
              emoji: f.emoji,
              bgColor: hexToColor(f.bgColorHex),
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${f.price}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    QtySelector(
                      qty: item.qty,
                      onDec: () => widget.cart.setQty(
                        f.id,
                        item.qty > 1 ? item.qty - 1 : 1,
                      ),
                      onInc: () => widget.cart.setQty(f.id, item.qty + 1),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => widget.cart.remove(f.id),
                      child: const Text(
                        'Remove',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(CartController cart) {
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.text2),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          row('Subtotal', 'Rs. ${cart.subtotal}'),
          row('Delivery Fee', 'Rs. ${cart.deliveryFee}'),
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
