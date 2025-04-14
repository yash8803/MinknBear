import 'dart:convert' show jsonDecode;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_address_add.dart';
import 'customer_address_edit.dart';

class CustomerAddresses extends StatefulWidget {
  const CustomerAddresses({super.key});

  @override
  State<CustomerAddresses> createState() => _CustomerAddressesState();
}

class _CustomerAddressesState extends State<CustomerAddresses> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _listViewController = ScrollController();
  String? _defaultAddressId;
  List? _addresses;
  bool _paginationLoading = false;
  Map? _paginationInfo;

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

  Future<void> _deleteAddress(String id) async {
    final client = GraphQLProvider.of(context).value;

    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded == null) {
      return;
    }

    Map customer = jsonDecode(customerEncoded);
    String accessToken = customer['accessToken'];

    final result = await client.mutate(MutationOptions(document: gql(r'''
					mutation customerAddressDelete($accessToken: String! $id: ID!) {
						customerAddressDelete (customerAccessToken: $accessToken id: $id) {

						}
					}
				'''), variables: {'accessToken': accessToken, 'id': id}));

    if (kDebugMode) {
      print(result);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your Address successfully deleted!')));
    }

    _getAddresses();
  }

  Future<void> _setDefaultAddress(String addressId) async {
    final client = GraphQLProvider.of(context).value;

    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded == null) {
      return;
    }

    Map customer = jsonDecode(customerEncoded);
    String accessToken = customer['accessToken'];

    final result = await client.mutate(MutationOptions(document: gql(r'''
					mutation customerDefaultAddressUpdate($accessToken: String! $addressId: ID!) {
						customerDefaultAddressUpdate (customerAccessToken: $accessToken addressId: $addressId) {
							customerUserErrors {
								code
								field
								message
							}
						}
					}
				'''), variables: {
      'accessToken': accessToken,
      'addressId': addressId,
    }));

    if (kDebugMode) {
      print(result);
    }

    if (context.mounted) {
      if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error! Message: ${result.exception!.graphqlErrors[0].message}')));
      } else {
        List errors =
        result.data!['customerDefaultAddressUpdate']['customerUserErrors'];

        if (errors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Your Address successfully set as default address')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error! Message: ${errors[0]['message']}')));
        }
      }
    }

    _getAddresses();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Shipping Addresses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 200));
                if (context.mounted) {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CustomerAddressAdd()));
                  _getAddresses();
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: _addresses == null
          ? Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
          strokeWidth: 3,
        ),
      )
          : _addresses!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses saved yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first shipping address',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
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
              onPressed: () async {
                await Future.delayed(
                    const Duration(milliseconds: 200));
                if (context.mounted) {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                      const CustomerAddressAdd()));
                  _getAddresses();
                }
              },
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Add Address',style: TextStyle(fontSize: 18),),

            ),
          ],
        ),
      )
          : NotificationListener<ScrollEndNotification>(
        onNotification: (scrollEnd) {
          if (scrollEnd.metrics.atEdge &&
              !scrollEnd.metrics.pixels.isNegative) {
            if (_paginationInfo != null &&
                _paginationInfo!['hasNextPage']) {
              setState(() => _paginationLoading = true);
              _getAddresses(after: _paginationInfo!['endCursor']);
            }
          }
          return false;
        },
        child: ListView.separated(
          controller: _listViewController,
          padding: const EdgeInsets.all(16),
          itemCount:
          _addresses!.length + (_paginationLoading ? 1 : 0),
          separatorBuilder: (context, index) =>
          const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == _addresses!.length) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 3,
                ),
              );
            }

            final address = _addresses![index]['node'];
            final isDefault = address['id'] == _defaultAddressId;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isDefault)
                              Container(
                                margin:
                                const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  Colors.green.withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Default',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          address['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          address['formatted'].join(', '),
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.4,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        if (isDefault)
                          Container(
                            child: Text('Its your default address now...', style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),),
                          ),
                        if (!isDefault)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _setDefaultAddress(address['id']),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Set as Default'),
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(130, 8),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await Future.delayed(const Duration(
                                    milliseconds: 200));
                                if (context.mounted) {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerAddressEdit(
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
                            IconButton(
                              onPressed: () =>
                                  _deleteAddress(address['id']),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                              color: Colors.red[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}