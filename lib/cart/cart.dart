import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopify_flutter/wishlist/wishlist.dart';

import '../customer/customer_address_add.dart';
import '../customer/customer_address_edit.dart';
import '../main.dart';
import '../policy/refund_policy.dart';
import 'cart_model.dart';
import 'cart_empty.dart';
import 'cart_line_item.dart';
import 'cart_checkout.dart';

const String getDefaultAddressQuery = r'''
  query getDefaultAddress($accessToken: String!) {
    customer(customerAccessToken: $accessToken) {
      defaultAddress {
    id
										address1
										address2
										city
										company
										country
										countryCodeV2
										firstName
										formatted
										formattedArea
										lastName
										latitude
										longitude
										name
										phone
										province
										provinceCode
										zip
      }
    }
  }
''';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ScrollController _scrollController = ScrollController();
  bool isAddressExpanded = false;
  List? _addresses;
  String? _defaultAddressId;
  bool _paginationLoading = false;
  Map? _paginationInfo;
  Future<Map<String, dynamic>?> _fetchDefaultAddress(
      BuildContext context) async {
    final client = GraphQLProvider.of(context).value;
    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded == null) return null;

    Map customer = jsonDecode(customerEncoded);
    String accessToken = customer['accessToken'];

    final result = await client.query(
      QueryOptions(
        document: gql(getDefaultAddressQuery),
        variables: {'accessToken': accessToken},
        fetchPolicy: FetchPolicy.noCache, // Use noCache to bypass cache issues
      ),
    );

    if (result.hasException) {
      if (kDebugMode) {
        print('GraphQL Exception: ${result.exception}');
      }
      return null;
    }

    final defaultAddress = result.data?['customer']['defaultAddress'];
    if (kDebugMode) {
      print('Fetched Default Address: $defaultAddress');
    }

    return defaultAddress;
  }

  Future<void> _getAddresses({int limit = 24, String? after}) async {
    final client = GraphQLProvider.of(context).value;

    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded == null) {
      return;
    }

    Map customer = jsonDecode(customerEncoded);
    String accessToken = customer['accessToken'];

    final result = await client.query(QueryOptions(document: gql(r'''
					query customer($accessToken: String! $limit: Int $after: String) {
						customer (customerAccessToken: $accessToken) {
							defaultAddress {
								id
							}
							addresses (first: $limit after: $after) {
								edges { 
									node {
										id
										address1
										address2
										city
										company
										country
										countryCodeV2
										firstName
										formatted
										formattedArea
										lastName
										latitude
										longitude
										name
										phone
										province
										provinceCode
										zip
									}
								}
								pageInfo {
									endCursor
									hasNextPage
								}
							}
						}
					}
				'''), variables: {
      'accessToken': accessToken,
      'limit': limit,
      'after': after,
    }));

    if (kDebugMode) {
      print(result);
    }

    setState(() {
      if (after == null) {
        _addresses = result.data!['customer']['addresses']['edges'];
      } else {
        _addresses = [
          ..._addresses!,
          ...result.data!['customer']['addresses']['edges']
        ];
      }

      if (result.data!['customer']['defaultAddress'] != null) {
        _defaultAddressId = result.data!['customer']['defaultAddress']['id'];
      }

      _paginationLoading = false;
      _paginationInfo = result.data!['customer']['addresses']['pageInfo'];
    });
  }

  @override
  void dispose() {
    // Don't forget to dispose of the controller when the widget is destroyed
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAddressWidget(Map<String, dynamic>? address) {
    final colorScheme = Theme.of(context).colorScheme;
    if (address == null) {
      return const Card(
        surfaceTintColor: primaryColor,
        color: primaryColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
          child: Row(
            children: [
              Icon(Icons.location_off, color: Colors.grey),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No default address found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    String shortAddress = '${address['address1']}, ${address['city']}';
    String fullAddress = '''
${address['firstName']} ${address['lastName']}
${address['address1']}
${address['address2'] ?? ''}
${address['city']}, ${address['province']}
${address['country']} - ${address['zip']}
${address['phone'] ?? ''}
''';

    return Card(
      color: seedColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: seedColor,
          initiallyExpanded: isAddressExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              isAddressExpanded = expanded;
            });
          },
          leading: const Icon(Icons.location_on, color: Colors.black87),
          title: Text(
            isAddressExpanded ? 'Delivery Address' : shortAddress,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        address!['firstName'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 200));
                          if (context.mounted) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CustomerAddressEdit(
                                  address: address,
                                ),
                              ),
                            );
                            _getAddresses();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        color: Colors.grey[700],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    '  ${address!['address1']}, ${address!['address2']}, ${address!['city']} - ${address!['zip']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),


                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${address!['province']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      if (address!['phone'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                address!['phone'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Divider(),
                  SizedBox(
                    width: 20,
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const CustomerAddressAdd()));
                        _getAddresses();
                      }
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add New Address'),
                    style: TextButton.styleFrom(
                      fixedSize: Size(430, 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      foregroundColor: colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Text(
            //     fullAddress,
            //     style: const TextStyle(
            //       fontSize: 14,
            //       color: Colors.black87,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    double totalAmount = double.tryParse(
      context
          .watch<CartModel>()
          .cart!['cost']['totalAmount']['amount']
          .toString(),
    ) ??
        0.0;

    double totalTaxAmount = 0.00;
    double totalDutyAmount = 0.00;
    double subtotalAmount = double.tryParse(
      context
          .watch<CartModel>()
          .cart!['cost']['subtotalAmount']['amount']
          .toString(),
    ) ??
        0.0;
    double amountPayable = totalAmount + totalTaxAmount;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: seedColor,
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline_outlined,
                color: Colors.black87),
            onPressed: () => _navigateWithSlide(context, const WishlistPage()),
          ),
        ],
      ),
      body: context.read<CartModel>().count == 0
          ? const CartEmpty()
          : Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Container(
                color: seedColor,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchDefaultAddress(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Text(
                          'Failed to load address',
                          style: TextStyle(color: Colors.red),
                        );
                      }
                      return _buildAddressWidget(snapshot.data);
                    },
                  ),
                ),
              ),
            ),
          ],
          body: Stack(
            fit: StackFit.expand,
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '${context.watch<CartModel>().count.toString()} items in your cart',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final edge = context
                            .watch<CartModel>()
                            .cart!['lines']['edges'][index];
                        return CartLineItem(
                          key: Key(edge['node']['id']),
                          lineItem: edge['node'],
                        );
                      },
                      childCount: context
                          .watch<CartModel>()
                          .cart!['lines']['edges']
                          .length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(.3),
                        ),
                        PaymentSummary(
                          totalAmount: totalAmount,
                          totalTaxAmount: totalTaxAmount,
                          amountPayable: amountPayable,
                          subtotalAmount: subtotalAmount,
                          totalDutyAmount: totalDutyAmount,
                        ),
                        Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(16.0),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Return/Refund policy',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Thank you for choosing Mink & Bear! We are dedicated to your satisfaction. Please review our return and exchange policy for more details.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _navigateWithSlide(
                                      context, RefundPolicyPage()),
                                  child: const Text(
                                    'Read Policy',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Add some bottom padding to ensure the last item
                        // is not obscured by the bottom bar
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16).copyWith(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _scrollToPaymentSummary();
                                },
                                child: const Text(
                                  'view details',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              if (context.mounted) {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CartCheckout(
                                        checkoutUrl: context
                                            .read<CartModel>()
                                            .cart!['checkoutUrl'],
                                      ),
                                    ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToPaymentSummary() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, // Scroll to the end
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
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

class PaymentSummary extends StatelessWidget {
  final double subtotalAmount;
  final double totalAmount;
  final double totalTaxAmount;
  final double totalDutyAmount;
  final double amountPayable;

  const PaymentSummary({
    super.key,
    required this.subtotalAmount,
    required this.totalAmount,
    required this.totalTaxAmount,
    required this.amountPayable,
    required this.totalDutyAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildRow('Sub Total Amount', subtotalAmount),
            _buildRow('Total Amount', totalAmount),
            _buildRow('Total Duty Amount', totalDutyAmount),
            _buildRow('Total Tax Amount', totalTaxAmount),
            const Divider(height: 24),
            _buildRow('Amount Payable', amountPayable, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.black54,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.black54,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
