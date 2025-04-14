import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shopify_flutter/offers.dart';
import '../../wishlist/wishlist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../collection/collection.dart';
import '../contact.dart';
import '../customer/customer_login.dart';
import '../customer/customer_profile.dart';
import '../main.dart';
import 'home_page.dart';
import '../product/product.dart';
import '../customer/customer_model.dart';
import '../customer/customer_orders.dart';
import '../customer/customer_addresses.dart';
import 'navigation_state.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool _showAccountMenu = false;
  final _loginFormKey = GlobalKey<FormState>();
  bool _loading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _menuItemOnTap(BuildContext context, Map item) async {
    await Future.delayed(const Duration(milliseconds: 200));

    switch (item['type']) {
      case 'COLLECTION':
        if (context.mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CollectionPage(
                title: item['title'],
                id: item['resourceId'],
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(3.0, 0.0); // Slide in from the right
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
        break;
      case 'PRODUCT':
        if (context.mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductPage(
                title: item['title'],
                id: item['resourceId'],
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(3.0, 0.0); // Slide in from the right
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
        break;
      case 'FRONTPAGE':
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Set index to 0 (home content)
          context.read<NavigationState>().setIndex(0);
          HomePage.scaffoldKey.currentState?.closeDrawer();                          }
        break;
      case 'PAGE':
        if (context.mounted) {
          if (item['title'] == 'Contact') {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const Contact(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(3.0, 0.0); // Slide in from the right
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          } else {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const OfferScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(3.0, 0.0); // Slide in from the right
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
            ;
          }
        }
        break;
      case 'HTTP':
        launchUrl(Uri.parse(item['url']));
        break;
      default:
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 200));
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await context.read<CustomerModel>().logout(context);

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Logged out')));
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<NavigationState>().setIndex(0);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      surfaceTintColor: primaryColor,
      width: 310,
      backgroundColor: primaryColor,
      child: Column(
        children: [
          if (context.watch<CustomerModel>().customer == null)
            DrawerHeader(

              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Theme.of(context).primaryColor.withOpacity(.8),
                Theme.of(context).primaryColor
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome guest',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(
                      'Please login or register',
                      style: TextStyle(color: Colors.black.withOpacity(.75)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const CustomerLogin(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(
                                          3.0, 0.0); // Slide in from the right
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Login or Register')),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          if (context.watch<CustomerModel>().customer != null)
            SizedBox(
              height: 170,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: Row(
                  children: [
                    Material(
                      elevation: 3, // Added elevation for a shadow effect
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.white,
                        child: Text(
                          (context
                                      .read<CustomerModel>()
                                      .customer?['firstName']
                                      ?.isNotEmpty ??
                                  false)
                              ? context
                                  .read<CustomerModel>()
                                  .customer!['firstName'][0]
                                  .toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.read<CustomerModel>().customer?['firstName'] ?? 'Guest'} '
                          '${context.read<CustomerModel>().customer?['lastName'] ?? ''}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          context.read<CustomerModel>().customer?['email'] ??
                              'No Email',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (!_showAccountMenu)
            Query(
                options: QueryOptions(document: gql(r"""
                      query menu($handle: String!) {
                        menu (handle: $handle) {
                          itemsCount
                          title
                          items {
                            title
                            url
                            type
                            resourceId
                            items {
                              title
                              url
                              type
                              resourceId
                            }
                          }
                        }
                      }
                    """), variables: {
                  'handle': dotenv.env['MAIN_MENU_HANDLE'],
                }),
                builder: (result, {fetchMore, refetch}) {
                  if (result.isLoading) {
                    return const Expanded(
                        child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        semanticsLabel: 'Loading, please wait',
                      ),
                    ));
                  }

                  if (kDebugMode) {
                    print(result);
                  }

                  if (result.data!['menu'] == null) {
                    return const Text('Menu not found!');
                  }

                  List menuItems = result.data!['menu']['items'];

                  return Expanded(
                      child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
                          children: menuItems.map((item) {
                            if (item['title'] == '-') {
                              return const Divider();
                            } else if (item['items'].isEmpty) {
                              return ListTile(
                                  title: Text(item['title']),
                                  trailing: item['type'] == 'HTTP'
                                      ? const Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(
                                            Icons.open_in_new,
                                            size: 18,
                                          ),
                                        )
                                      : null,
                                  onTap: () => _menuItemOnTap(context, item));
                            } else {
                              return Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    title: Text(item['title']),
                                    children: [
                                      for (Map item in item['items'])
                                        ListTile(
                                          dense: true,
                                          title: Text(
                                            item['title'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400),
                                          ),
                                          onTap: () =>
                                              _menuItemOnTap(context, item),
                                        ),
                                    ],
                                  ));
                            }
                          }).toList()));
                }),
          if (_showAccountMenu)
            Expanded(
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
                    children: [
                  ListTile(
                      title: const Text(
                        'PROFILE',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const CustomerProfile(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(3.0, 0.0); // Slide in from the right
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      }),
                  ListTile(
                      title: const Text(
                        'ORDERS',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const CustomerOrders(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(3.0, 0.0); // Slide in from the right
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      }),
                  ListTile(
                      title: const Text(
                        'WISHLIST',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const WishlistPage()));
                        }
                      }),
                  ListTile(
                      title: const Text(
                        'ADDRESS',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const CustomerAddresses()));
                        }
                      }),
                  ListTile(
                      title: const Text(
                        'SETTINGS',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const CustomerOrders(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(3.0, 0.0); // Slide in from the right
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      }),
                  ListTile(
                      title: const Text(
                        'CONTACT US',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const CustomerOrders()));
                        }
                      }),
                  ListTile(
                      title: const Text(
                        'LOGOUT',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        await context.read<CustomerModel>().logout(context);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out')));
                      }),
                ])),
          if (context.watch<CustomerModel>().customer != null)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Container(
              //     // color: Colors.red,
              //     padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
              //     child: Icon(Icons.person_2_outlined)),
              // Container(
              //   // color: Colors.yellow,
              //   padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
              //   child: Text(
              //     '${context.read<CustomerModel>().customer!['firstName']} ',
              //     style: TextStyle(fontSize: 16),
              //   ),
              // ),
              Container(
                // color: Colors.green,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),

                child: ElevatedButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 200));

                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ]),
        ],
      ),
    );
  }
}
