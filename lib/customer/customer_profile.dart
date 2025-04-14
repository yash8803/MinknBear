import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'customer_model.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({super.key});

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isInitialized = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final customer = context
          .watch<CustomerModel>()
          .customer;

      if (customer != null) {
        _fnameController = TextEditingController(text: customer?['firstName']??'');
        _lnameController = TextEditingController(text: customer?['lastName']??'');
        _emailController = TextEditingController(text: customer?['email']??'');
        _phoneController = TextEditingController(text: customer?['phone']??'');

        _isInitialized = true;
      }
    }
  }
  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'firstName': _fnameController.text,
        'lastName': _lnameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      // Call the update method and wait for it to complete
      try {
        await context.read<CustomerModel>().updateCustomer(updatedData, context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update details. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerModel>().customer;

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile'),scrolledUnderElevation: 0, // Prevents elevation change on scroll
          shadowColor: Colors.transparent, // Removes shadow when scrolling
          surfaceTintColor: Colors.transparent, ),
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile'),scrolledUnderElevation: 0, // Prevents elevation change on scroll
        shadowColor: Colors.transparent, // Removes shadow when scrolling
        surfaceTintColor: Colors.transparent, ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                inputFormatters: [ FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                ],
                controller: _fnameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.name,
                inputFormatters: [ FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                ],
                controller: _lnameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // if (!RegExp(r'^\d+$').hasMatch(value)) {
                  //   return 'Please enter a valid phone number';
                  // }1
                  // if (value.length != 10) {
                  //   return 'Phone number must be 10 digits';
                  // }
                  return null;
                },
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                  onPressed:
                    _submitForm,

                  child: _loading
                      ? const SizedBox(
                    height: 19,
                    width: 19,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}