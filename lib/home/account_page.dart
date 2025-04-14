import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify_flutter/home/user_info.dart';
import '../customer/customer_login.dart';
import '../customer/customer_model.dart';
import 'menu_item.dart';


class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Map<String, dynamic> _castCustomerData(Map<dynamic, dynamic>? data) {
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerModel>(
      builder: (context, model, child) {
        final customer = _castCustomerData(model.customer);
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (model.customer == null)
              const GuestView()
            else ...[
              UserInfo(customer: customer),
              const SizedBox(height: 16),
              MenuItems(customer: customer),
            ],
          ],
        );
      },
    );
  }
}


class GuestView extends StatelessWidget {
  const GuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
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
              'Sign in to view your profile,Orders and many more',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerLogin()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign In', style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}