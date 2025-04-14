import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopify_flutter/search.dart';
import 'package:shopify_flutter/settings.dart';
import 'cart/cart.dart';
import 'cart/cart_model.dart';
import 'collection/collection.dart';
import 'customer/customer_addresses.dart';
import 'customer/customer_login_register.dart';
import 'customer/customer_model.dart';
import 'customer/customer_orders.dart';
import 'customer/customer_profile.dart';
import 'main.dart';
import 'wishlist/wishlist.dart';

class MainBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
            onPressed: () => _navigateWithSlide(context, const SearchPage()),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Colors.black87),
            onPressed: () => _navigateWithSlide(context, const WishlistPage()),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_rounded, color: Colors.black87),
                onPressed: () => _navigateWithSlide(context, const CartPage()),
              ),
              if (context.watch<CartModel>().count > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      context.watch<CartModel>().count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
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
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(r"""
          query collections() {
            collections (first: 50) {
              edges {
                node {
                  id,
                  title,
                  handle,
                  description,
                  image {
                    transformedSrc(maxWidth: 900, maxHeight: 720)
                    altText
                  }
                }
              }
            }
          }
        """),
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (result.hasException) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load collections',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: result.data!['collections']['edges'].length,
          itemBuilder: (context, index) {
            final edge = result.data!['collections']['edges'][index];
            return buildCollectionCard(edge, context);
          },
        );
      },
    );
  }

  Widget buildCollectionCard(dynamic edge, BuildContext context) {
    var node = edge['node'];
    var imageUrl = node['image']?['transformedSrc'] ?? '';
    var title = node['title'] ?? '';

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToCollection(context, node),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: 'collection-${node['id']}',
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const SkeletonLoader(),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.error_outline),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCollection(BuildContext context, dynamic node) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CollectionPage(
                id: node['id'],
                title: node['title'],
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerModel>().customer;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (customer == null)
          _buildGuestView(context)
        else ...[
          _buildUserInfoSection(customer),
          const SizedBox(height: 16),
          _buildMenuItems(context, customer),
        ],
      ],
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Welcome to our store',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to view your profile and orders',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerLoginRegister()),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey.shade100,
            child: Text(
              '${customer['firstName']} ${customer['lastName']}'.isNotEmpty
                  ? '${customer['firstName']}'.substring(0, 1).toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${customer['firstName']} ${customer['lastName']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${customer['email']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, dynamic customer) {
    final menuItems = [
      {
        'title': 'Profile',
        'icon': Icons.person_rounded,
        'route': const CustomerProfile(),
      },
      {
        'title': 'Orders',
        'icon': Icons.shopping_bag_rounded,
        'route': const CustomerOrders(),
      },
      {
        'title': 'Addresses',
        'icon': Icons.location_on_rounded,
        'route': const CustomerAddresses(),
      },
      {
        'title': 'Settings',
        'icon': Icons.settings_rounded,
        'route': SettingsPage(
          userName: '${customer['firstName']} ${customer['lastName']}',
          userEmail: '${customer['email']}',
        ),
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return ListTile(
          leading: Icon(item['icon'] as IconData, color: Colors.grey.shade700),
          title: Text(item['title'] as String),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item['route'] as Widget),
          ),
        );
      }).toList(),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}