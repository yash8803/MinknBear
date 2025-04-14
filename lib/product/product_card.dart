import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../cart/cart.dart';
import '../cart/cart_model.dart';
import '../wishlist/wishlist.dart';
import 'product.dart';
import 'product_rating_stars.dart';

class ProductCard extends StatefulWidget {
  final Map product;

  const ProductCard({super.key, required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Helper function to format price with decimal handling
    String formatPrice(double price) {
      return '\₹${price % 1 == 0 ? price.toStringAsFixed(0) : price.toStringAsFixed(2)}';
    }

    // Calculate discount percentage safely
    double calculateDiscountPercentage(double originalPrice, double discountedPrice) {
      if (originalPrice <= 0 || originalPrice <= discountedPrice) return 0.0;
      return ((originalPrice - discountedPrice) / originalPrice) * 100;
    }

    final product = widget.product as Map<String, dynamic>;
    if (product['images'] == null || product['images']['edges'] == null) {
      return Card(
        child: SizedBox(
          height: screenHeight * 0.3,
          child: const Center(child: Text('No Image Available')),
        ),
      );
    }

    // Extract price details with fallback
    double originalPrice = double.tryParse(
        product['compareAtPriceRange']?['minVariantPrice']?['amount']?.toString() ?? '0') ?? 0.0;
    double discountedPrice = double.tryParse(
        product['priceRange']?['minVariantPrice']?['amount']?.toString() ?? '0') ?? 0.0;

    final featuredImageUrl = product['featuredImage']?['url'] as String? ?? '';

    return GestureDetector(
      onTap: () async {
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ProductPage(
                id: product['id'] as String? ?? '',
                title: product['title'] as String? ?? 'Untitled',
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        }
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
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: featuredImageUrl,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(child: Icon(Icons.error)),
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['title'] as String? ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        ProductRatingStars(
                          metafields: product['metafields'],
                          compact: true,
                        ),
                        SizedBox(height: screenHeight * 0.007),
                        Row(
                          children: [
                            Text(
                              formatPrice(discountedPrice),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            if (originalPrice > discountedPrice) ...[
                              Padding(
                                padding: EdgeInsets.only(right: screenWidth * 0.01),
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Text(
                                    formatPrice(originalPrice),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: screenWidth * 0.02),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02,
                                  vertical: screenHeight * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${calculateDiscountPercentage(originalPrice, discountedPrice).round()}% OFF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: screenHeight * 0.01,
              right: screenWidth * 0.02,
              child: Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  final productId = product['id'] as String? ?? '';
                  final isWishlisted = wishlistProvider.isWishlisted(productId);

                  return Container(
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(6),
                      iconSize: 24,
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        wishlistProvider.toggleWishlist(product);
                        final message = isWishlisted
                            ? 'Removed from Wishlist!'
                            : 'Added to Wishlist!';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                    ),
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