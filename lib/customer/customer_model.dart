import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CustomerModel with ChangeNotifier {
  Map? _customer;

  Map? get customer => _customer;

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer');
    _customer = null;
    notifyListeners();
  }

  Future<void> initializeCustomer(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded != null) {
      Map customer = jsonDecode(customerEncoded);

      // Check if the session is expired
      DateTime expiresAt = DateTime.parse(customer['expiresAt']);
      if (expiresAt.isBefore(DateTime.now())) {
        await prefs.remove('customer');
        _customer = null;
        notifyListeners();
        return;
      }

      // If session is valid, fetch fresh data from server
      if (context.mounted) {
        await getCustomer(context);
      }
    } else {
      _customer = null;
      notifyListeners();
    }
  }

  Future<void> getCustomer(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;
    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded == null) {
      _customer = null;
      notifyListeners();
      return;
    }

    Map customer = jsonDecode(customerEncoded);

    // Check if the customer session is valid
    DateTime expiresAt = DateTime.parse(customer['expiresAt']);
    if (expiresAt.isBefore(DateTime.now())) {
      await prefs.remove('customer');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
        ));
      }
      _customer = null;
      notifyListeners();
      return;
    }

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(r'''
          query customer($accessToken: String!) {
            customer(customerAccessToken: $accessToken) {
              id
              firstName
              lastName
              phone
              email
            }
          }
        '''),
          variables: {'accessToken': customer['accessToken']},
        ),
      );

      if (result.data != null && result.data!['customer'] != null) {
        _customer = result.data!['customer'];
        // Update the stored customer data with fresh data from server
        await prefs.setString('customer', jsonEncode({
          'accessToken': customer['accessToken'],
          'expiresAt': customer['expiresAt'],
          'id': _customer!['id'],
          'firstName': _customer!['firstName'],
          'lastName': _customer!['lastName'],
          'email': _customer!['email'],
          'phone': _customer!['phone'],
        }));
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching customer data: $e');
      }
    }
  }

  Future<void> updateCustomer(Map<String, String> updatedData, BuildContext context) async {
    final client = GraphQLProvider.of(context).value;
    final prefs = await SharedPreferences.getInstance();
    String? customerEncoded = prefs.getString('customer');

    if (customerEncoded == null) return;

    Map customer = jsonDecode(customerEncoded);

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(r'''
          mutation updateCustomer($accessToken: String!, $customer: CustomerUpdateInput!) {
            customerUpdate(customerAccessToken: $accessToken, customer: $customer) {
              customer {
                id
                firstName
                lastName
                email
                phone
              }
              userErrors {
                field
                message
              }
            }
          }
        '''),
          variables: {
            'accessToken': customer['accessToken'],
            'customer': {
              'firstName': updatedData['firstName']!,
              'lastName': updatedData['lastName']!,
              'email': updatedData['email']!,
              'phone': updatedData['phone']!,
            },
          },
        ),
      );

      List errors = result.data!['customerUpdate']['userErrors'];

      if (errors.isNotEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error! Message: ${errors[0]['message']}'),
          ));
        }
        return;
      }

      // Update the provider state with new customer data
      _customer = result.data!['customerUpdate']['customer'];

      // Save the updated customer data in SharedPreferences
      await prefs.setString('customer', jsonEncode({
        'accessToken': customer['accessToken'],
        'expiresAt': customer['expiresAt'],
        'id': _customer!['id'],
        'firstName': _customer!['firstName'],
        'lastName': _customer!['lastName'],
        'email': _customer!['email'],
        'phone': _customer!['phone'],
      }));

      notifyListeners();

      // Fetch fresh data from server to ensure everything is in sync
      if (context.mounted) {
        await getCustomer(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating customer data: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
        ));
      }
    }
  }

}
