import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify_flutter/home/home_page.dart';
import 'package:shopify_flutter/search.dart';
import 'cart/cart.dart';
import 'cart/cart_model.dart';
import 'package:animate_do/animate_do.dart';

import 'home/navigation_state.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text(
          'Get Offers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchPage()),
            ),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CartPage()),
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.white),
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
      body: Stack(
        children: [
          FadeInDownBig(
            duration: Duration(milliseconds: 700),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/finalbanner.jpg'),
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeInUp(
                      duration: Duration(milliseconds: 700),
                      child: _buildOfferCard(
                        title: "Double Delight",
                        description:
                        "Buy 2 products and enjoy Rs. 120 OFF your purchase.",
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      duration: Duration(milliseconds: 900),
                      child: _buildOfferCard(
                        title: "Triple Treat",
                        description:
                        "Buy 3 products and receive Rs. 200 OFF your total.",
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        // decoration: BoxDecoration(
                        //   color: Colors.black.withOpacity(0.8),
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                        child: const Text(
                          "Note: All discounts are automatically applied at checkout. Elevate your style with Mink & Bear's collections!",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            // Set index to 0 (home content)
                            context.read<NavigationState>().setIndex(0);
                            HomePage.scaffoldKey.currentState?.closeDrawer();                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.white),
                          ),
                        ),

                        child: const Text(
                          "Continue Shopping",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String description,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      shadowColor: Colors.black87,
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
