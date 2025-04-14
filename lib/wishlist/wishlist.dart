import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify_flutter/main.dart';
import 'package:shopify_flutter/product/product.dart';
import '../cart/cart.dart';
import '../cart/cart_model.dart';
import 'WishlistDbHelper.dart';

class WishlistProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _wishlist = [];

  List<Map<String, dynamic>> get wishlist => _wishlist;

  Future<void> loadWishlist() async {
    final products = await WishlistDatabaseHelper.getAllProducts();
    _wishlist = products;
    notifyListeners();
  }

  bool isWishlisted(String productId) {
    return _wishlist.any((product) => product['id'] == productId);
  }

  Future<void> toggleWishlist(Map<String, dynamic> product) async {
    if (isWishlisted(product['id'])) {
      await WishlistDatabaseHelper.removeProduct(product['id']);
      _wishlist.removeWhere((item) => item['id'] == product['id']);
    } else {
      await WishlistDatabaseHelper.addProduct(product);
      _wishlist.add(product);
    }
    notifyListeners();
  }
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int _currentSlide = 0;
  late CarouselSliderController _controller;
  int _qty = 1;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
    Provider.of<WishlistProvider>(context, listen: false).loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlist = wishlistProvider.wishlist;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0, // Prevents elevation change on scroll
        shadowColor: Colors.transparent, // Removes shadow when scrolling
        surfaceTintColor: Colors.transparent, // Removes surface tint effect
        title: const Text('My Wishlist'),
        backgroundColor: seedColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (context.watch<CartModel>().count > 0)
                  Positioned(
                    top: 0,
                    right: -6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.yellow.shade900,
                      child: Text(
                        context.watch<CartModel>().count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: wishlist.isEmpty
          ? const Center(child: Text('Your wishlist is empty!'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 13,
                ),
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final product = wishlist[index];

                  final selectedVariant =
                      product['variants']?['edges']?.isNotEmpty == true
                          ? product['variants']['edges'][0]['node']
                          : null;

                  if (selectedVariant == null) {
                    return Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'No variants available',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final double compareAtPrice =
                      selectedVariant['compareAtPrice']?['amount'] != null
                          ? double.tryParse(selectedVariant['compareAtPrice']
                                  ['amount']) ??
                              0
                          : 0;

                  final double price =
                      double.tryParse(selectedVariant['price']['amount']) ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductPage(
                            id: product['id'],
                            title: product['title'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: CarouselSlider(
                                    carouselController: _controller,
                                    options: CarouselOptions(
                                      initialPage: _currentSlide,
                                      viewportFraction: 1,
                                      aspectRatio: 1,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentSlide = index;
                                        });
                                      },
                                    ),
                                    items: (product['images']?['edges'] ?? [])
                                        .map<Widget>((item) {
                                      return CachedNetworkImage(
                                        imageUrl: item['node']
                                                ?['transformedSrc'] ??
                                            '',
                                        placeholder: (context, url) =>
                                            Container(
                                                color: Colors.grey.shade100),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    }).toList(),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                      if (compareAtPrice > 0)
                                        Text(
                                          '₹${compareAtPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '₹${price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          if (compareAtPrice > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${(((compareAtPrice - price) / compareAtPrice) * 100).round()}% OFF',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.black,
                                              size: 25,
                                            ),
                                            onPressed: () {
                                              wishlistProvider
                                                  .toggleWishlist(product);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    content: Text(
                                                        'Removed from Wishlist')),
                                              );
                                            },
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              showSizeSelectionPopup(
                                                context,
                                                product,
                                                (String selectedSize) {
                                                  // Find the variant that matches the selected size
                                                  final variant =
                                                      product['variants']
                                                              ['edges']
                                                          .firstWhere(
                                                    (edge) => edge['node']
                                                            ['title']
                                                        .toString()
                                                        .contains(selectedSize),
                                                    orElse: () =>
                                                        product['variants']
                                                            ['edges'][0],
                                                  )['node'];

                                                  context
                                                      .read<CartModel>()
                                                      .cartLinesAdd(
                                                    context,
                                                    [
                                                      {
                                                        'merchandiseId':
                                                            variant['id'],
                                                        'quantity': _qty,
                                                      }
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 10,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Add to Cart',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class SizeSelectionPopup extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(String) onSizeSelected;

  const SizeSelectionPopup({
    Key? key,
    required this.product,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  State<SizeSelectionPopup> createState() => _SizeSelectionPopupState();
}

class _SizeSelectionPopupState extends State<SizeSelectionPopup> {
  String? _selectedSize;
  late ConfettiController _controllerCenter;
  List<String> _getSizes() {
    if (widget.product['options'] == null) return [];

    for (var option in (widget.product['options'] as List)) {
      if (option['name'].toString().toLowerCase() == 'size') {
        return (option['values'] as List).cast<String>();
      }
      if (option['name'].toString().toLowerCase() == 'title') {
        return (option['values'] as List).cast<String>();
      }
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 15));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _getSizes();

    return AlertDialog(
      title: Text('Select Size for ${widget.product['title']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sizes.isEmpty)
              const Text('No sizes available for this product.')
            else
              Wrap(
                spacing: 8.0,
                children: sizes.map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: _selectedSize == size,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSize = selected ? size : null;
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedSize != null
              ? () {
                  widget.onSizeSelected(_selectedSize!);
                }
              : null,
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}

Future<void> showSizeSelectionPopup(
  BuildContext context,
  Map<String, dynamic> product,
  Function(String) onSizeSelected,
) async {
  final List<String> sizes = [];
  if (product['options'] != null) {
    for (var option in (product['options'] as List)) {
      if (option['name'].toString().toLowerCase() == 'size' ||
          option['name'].toString().toLowerCase() == 'title') {
        sizes.addAll((option['values'] as List).cast<String>());
      }
    }
  }

  if (sizes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No sizes available for this product')),
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: seedColor,
    showDragHandle:true ,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (BuildContext context) {
      String? selectedSize;
      final confettiController = ConfettiController(
        duration: const Duration(seconds: 2),
      );

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Size for ${product['title']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: sizes.map((size) {
                    return ChoiceChip(
                      label: Text(
                        size,
                        style: TextStyle(
                          color: selectedSize == size
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: selectedSize == size,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          selectedSize = selected ? size : null;
                        });
                      },
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: selectedSize != null
                      ? () {
                          Navigator.pop(context);
                          onSizeSelected(selectedSize!);

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              confettiController.play();
                              return Stack(
                                children: [
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Hurrehhhh!!! \n Your ${product['title']} added to cart! \n (Size: $selectedSize)',
                                          style: const TextStyle(fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const CartPage(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text(
                                            'View Cart',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ConfettiWidget(
                                      confettiController: confettiController,
                                      blastDirectionality:
                                          BlastDirectionality.explosive,
                                      shouldLoop: false,
                                      colors: const [
                                        Colors.black,
                                        Colors.grey,
                                         Colors.white,
                                      ],

                                      createParticlePath : (Size size) {
                                        double degToRad(double deg) =>
                                            deg * (pi / 180.0);
                                        const numberOfPoints = 5;
                                        final halfWidth = size.width / 2;
                                        final externalRadius = halfWidth;
                                        final internalRadius = halfWidth / 2.5;
                                        final degreesPerStep =
                                            degToRad(360 / numberOfPoints);
                                        final halfDegreesPerStep =
                                            degreesPerStep / 2;
                                        final path = Path();
                                        path.moveTo(size.width, halfWidth);

                                        for (double step = 0;
                                            step < degToRad(360);
                                            step += degreesPerStep) {
                                          path.lineTo(
                                              halfWidth +
                                                  externalRadius * cos(step),
                                              halfWidth +
                                                  externalRadius * sin(step));
                                          path.lineTo(
                                              halfWidth +
                                                  internalRadius *
                                                      cos(step +
                                                          halfDegreesPerStep),
                                              halfWidth +
                                                  internalRadius *
                                                      sin(step +
                                                          halfDegreesPerStep));
                                        }
                                        path.close();
                                        return path;
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ).then((_) => confettiController.dispose());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
