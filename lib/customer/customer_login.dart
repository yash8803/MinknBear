import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_page.dart';
import '../home/navigation_state.dart';
import '../main.dart';
import 'customer_model.dart';
import 'customer_registration.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  final _loginFormKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordObscure = true;
  bool _loading = false;

  void _navigateWithSlide(BuildContext context, Widget page) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      Navigator.of(context).pop(
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

  Future<void> _login(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final client = GraphQLProvider.of(context).value;

    final result = await client.mutate(MutationOptions(
      document: gql(r'''
        mutation customerAccessTokenCreate ($input: CustomerAccessTokenCreateInput!) {
          customerAccessTokenCreate(input: $input)  {
            customerAccessToken {
              accessToken
              expiresAt
            }
            customerUserErrors {
              code
              field
              message
            }
          }
        }
      '''),
      variables: {
        'input': {
          'email': _emailController.text,
          'password': _passwordController.text,
        }
      },
    ));

    if (kDebugMode) {
      print(result);
    }

    List errors =
    result.data!['customerAccessTokenCreate']['customerUserErrors'];

    if (errors.isNotEmpty) {
      setState(() {
        _loading = false;
      });

      if (context.mounted) {
        _showAlertDialog(context, 'Error','Your E-mail or Password is Incorrrect\n Please Enter Correct Information.',Icons.info_outline
        );
      }
      return;
    }

    Map accessToken =
    result.data!['customerAccessTokenCreate']['customerAccessToken'];

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        'customer',
        jsonEncode({
          'accessToken': accessToken['accessToken'],
          'expiresAt': accessToken['expiresAt'],
        }));

    if (context.mounted) {
      await context.read<CustomerModel>().getCustomer(context);

      _showAlertDialog(
        context,
        'Success',
        'Successfully logged-in! Please wait...',Icons.check_circle_outline,
        autoClose: true,
        onClose: () {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            // Set index to 0 (home content)
            context.read<NavigationState>().setIndex(0);
            HomePage.scaffoldKey.currentState?.closeDrawer();
          }
        },
      );

    }

    setState(() {
      _loading = false;
    });
  }


  void _showAlertDialog(BuildContext context, String title, String message1,IconData icon,
      {bool autoClose = false,
        VoidCallback? onClose,
          }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context)  {
        if (autoClose) {
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              Navigator.of(context).pop();
              onClose?.call();
            }
          });
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: primaryColor, // Theme-aligned
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 50, color: title=="Success"?Colors.green:Colors.red),
                const SizedBox(height: 10),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                Text(

                  message1,
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Action buttons
                if (!autoClose)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.grey[200]
                        ),
                        child: const Text("OK",style: TextStyle(fontSize: 15),),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _resetPassword(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final client = GraphQLProvider.of(context).value;

    final result = await client.mutate(MutationOptions(
      document: gql(r'''
        mutation customerRecover ($email: String!) {
          customerRecover(email: $email)  {
            customerUserErrors {
              code
              field
              message
            }
          }
        }
      '''),
      variables: {'email': _emailController.text},
    ));

    setState(() {
      _loading = false;
    });

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (result.hasException) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error! Message: ${result.exception!.graphqlErrors[0].message}')));
      }
      return;
    }

    List errors = result.data!['customerRecover']['customerUserErrors'];

    if (context.mounted) {
      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error! Message: ${errors[0]['message']}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'We\'ve sent you an email with a link to update your password.')));
      }
    }
  }

  Future<void> _forgotPassword() async {
    await showModalBottomSheet<void>(
      backgroundColor: primaryColor,

      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AutofillGroup(
                child: Form(
                    key: _forgotPasswordFormKey,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16, 16, 16, MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Reset your password',
                              style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 6),
                          const Text(
                              'We will send you an email to reset your password...',
                              style: TextStyle()),
                          const SizedBox(height: 18),
                          _buildTextField(


                            controller: _emailController,
                            label: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  if (_forgotPasswordFormKey.currentState!
                                      .validate()) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    _resetPassword(context);
                                  }
                                },
                                child: _loading
                                    ? const SizedBox(
                                  height: 19,
                                  width: 19,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await Future.delayed(
                                      const Duration(milliseconds: 200));
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                )),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    )),
              );
            });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _passwordObscure,
      keyboardType: keyboardType ?? TextInputType.text,
      autofillHints: isPassword
          ? [AutofillHints.password]
          : [AutofillHints.email], // Add autofill hints
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _passwordObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _passwordObscure = !_passwordObscure;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      onEditingComplete: isPassword
          ? () => TextInput.finishAutofillContext() // Finish autofill on password submission
          : null,
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String text,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AutofillGroup(
              child: Form(
                key: _loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/mnb_splash.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Log in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword, // Better for password autofill
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildPrimaryButton(
                      onPressed: () {
                        if (_loginFormKey.currentState!.validate()) {
                          _login(context);
                          TextInput.finishAutofillContext(); // Save autofill data on login
                        }
                      },
                      text: 'Log In',
                      isLoading: _loading,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerRegister(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            children: const [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Register Here',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}