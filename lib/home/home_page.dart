import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shopify_flutter/home/drawer.dart';
import 'package:shopify_flutter/home/categories.dart';
import '../cart/cart.dart';
import '../cart/cart_model.dart';
import '../customer/customer_model.dart';
import '../search.dart';
import '../wishlist/wishlist.dart';
import 'account_page.dart';
import 'bottom_navigation.dart';
import 'home_content.dart';
import 'navigation_state.dart';

class HomePage extends StatefulWidget {
  // Define the GlobalKey as a static variable
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const CategoriesPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CartModel>().getCart(context);
      context.read<CustomerModel>().getCustomer(context);
      final customerModel = Provider.of<CustomerModel>(context, listen: false);
      customerModel.getCustomer(context);
    });
  }

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateWithSlide(BuildContext context, Widget page) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<NavigationState>();
    return Consumer<NavigationState>(
      builder: (context, navigationState, child) {
        return Scaffold(
          key: HomePage.scaffoldKey, // Assign the static GlobalKey to the Scaffold
          appBar: _buildAppBar(),
          drawer: const MyDrawer(),
          body: _pages[navigationState.currentIndex],
          bottomNavigationBar: MainBottomNav(
            currentIndex: navigationState.currentIndex,
            onTap: (index) => navigationState.setIndex(index),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      title: Text(
        dotenv.env['STORE_NAME']!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      actions: [
        _buildActionButton(
          icon: Icons.search_rounded,
          onPressed: () => _navigateWithSlide(context, const SearchPage()),
        ),
        _buildActionButton(
          icon: Icons.favorite_outline_rounded,
          onPressed: () => _navigateWithSlide(context, const WishlistPage()),
        ),
        _buildCartButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.black87),
      onPressed: onPressed,
    );
  }

  Widget _buildCartButton() {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
              onPressed: () => _navigateWithSlide(context, const CartPage()),
            ),
            if (cart.count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cart.count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}