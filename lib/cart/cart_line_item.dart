import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../product/product_selected_variant_model.dart';
import 'cart_model.dart';
import '../product/product.dart';

class CartLineItem extends StatefulWidget {
  final Map lineItem;

  const CartLineItem({
    super.key,
    required this.lineItem,
  });

  @override
  State<CartLineItem> createState() => _CartLineItemState();
}

class _CartLineItemState extends State<CartLineItem> {
  bool _cardLoading = false;
  late int _qty;

  Future<void> _updateQuantity(int qty) async {
    setState(() {
      _cardLoading = true;
      _qty = qty;
    });
    await context
        .read<CartModel>()
        .cartLinesUpdate(context, widget.lineItem['id'], qty);
    setState(() {
      _cardLoading = false;
    });
  }

  Future<void> _removeCartItem() async {
    setState(() {
      _cardLoading = true;
    });
    await context
        .read<CartModel>()
        .cartLinesRemove(context, widget.lineItem['id']);
    setState(() {
      _cardLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _qty = widget.lineItem['quantity'];
  }

  @override
  Widget build(BuildContext context) {
    final double unitPrice =
    double.parse(widget.lineItem['cost']['amountPerQuantity']['amount']);
    final double comparativePrice = double.parse(
        widget.lineItem['cost']['compareAtAmountPerQuantity']['amount']);
    final double Price = unitPrice * _qty;
    void _navigateToProduct() {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ProductPage(
            id: widget.lineItem['merchandise']['product']['id'],
            title: widget.lineItem['merchandise']['product']['title'],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
    return AnimatedOpacity(
        opacity: _cardLoading ? 0.5 : 1,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(  // Add this
            onTap: _navigateToProduct,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(1, 10, 1, 0),
                child:
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(1)),
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: CachedNetworkImage(

                              imageUrl: widget.lineItem['merchandise']['image']
                              ['transformedSrc'] ??
                                  '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade50,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    widget.lineItem['merchandise']['product']['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    // First Container (Title)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // Increased padding
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        widget.lineItem['merchandise']['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),  // Consistent spacing
                                    // Second Container (Quantity Control)
                                    Container(
                                      height: 36,  // Fixed height for consistency
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 32,  // Fixed width for buttons
                                            height: 32, // Fixed height for buttons
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                if (_qty > 1) {
                                                  setState(() {
                                                    _qty -= 1;
                                                    _updateQuantity(_qty);
                                                  });
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 32,  // Fixed width for quantity display
                                            alignment: Alignment.center,
                                            child: Text(
                                              _qty.toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 32,  // Fixed width for buttons
                                            height: 32, // Fixed height for buttons
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                setState(() {
                                                  _qty += 1;
                                                  _updateQuantity(_qty);
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        '₹${unitPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                          '₹${comparativePrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              decoration: TextDecoration.lineThrough)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${(((comparativePrice! - unitPrice) / comparativePrice!) * 100).round()}% OFF',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child:  Text(
                                    'You Save ₹${((comparativePrice! - unitPrice)).round()}.00',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _removeCartItem,
                          icon: const Icon(Icons.delete_outline, size: 18 ,),
                          label: const Text('Remove'),
                          style: TextButton.styleFrom(

                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.only(right: 5)),
                        ),
                      ],
                    ),
                  ],
                ),

              ),
            ))
    );

  }

}