import 'package:flutter/material.dart';

import '../customer/customer_addresses.dart';
import '../customer/customer_orders.dart';
import '../customer/customer_profile.dart';
import '../settings.dart';

class MenuItems extends StatelessWidget {
  final Map<String, dynamic> customer;

  const MenuItems({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
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
