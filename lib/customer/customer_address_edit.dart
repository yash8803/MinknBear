import 'dart:convert' show jsonDecode;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<String> addressFields = [
  'Flat/Building Name',
  'Area/Street',
  'Postal/Zip code',
  'City',
  'Country',
  'State',
];

final List<String> contactFields = ['First name', 'Last name', 'Phone'];

final List<String> countries = [
  'Afghanistan',
  'Åland Islands',
  'Albania',
  'Algeria',
  'Andorra',
  'Angola',
  'Anguilla',
  'Antigua and Barbuda',
  'Argentina',
  'Armenia',
  'Aruba',
  'Ascension Island',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bahamas',
  'Bahrain',
  'Bangladesh',
  'Barbados',
  'Belarus',
  'Belgium',
  'Belize',
  'Benin',
  'Bermuda',
  'Bhutan',
  'Bolivia',
  'Bosnia and Herzegovina',
  'Botswana',
  'Brazil',
  'British Indian Ocean Territory',
  'British Virgin Islands',
  'Brunei',
  'Bulgaria',
  'Burkina Faso',
  'Burundi',
  'Cambodia',
  'Cameroon',
  'Canada',
  'Cape Verde',
  'Caribbean Netherlands',
  'Cayman Islands',
  'Central African Republic',
  'Chad',
  'Chile',
  'China',
  'Christmas Island',
  'Cocos (Keeling) Islands',
  'Colombia',
  'Comoros',
  'Congo - Brazzaville',
  'Congo - Kinshasa',
  'Cook Islands',
  'Costa Rica',
  'Croatia',
  'Curaçao',
  'Cyprus',
  'Czechia',
  'Côte d"Ivoire',
  'Denmark',
  'Djibouti',
  'Dominica',
  'Dominican Republic',
  'Ecuador',
  'Egypt',
  'El Salvador',
  'Equatorial Guinea',
  'Eritrea',
  'Estonia',
  'Eswatini',
  'Ethiopia',
  'Falkland Islands',
  'Faroe Islands',
  'Fiji',
  'Finland',
  'France',
  'French Guiana',
  'French Polynesia',
  'French Southern Territories',
  'Gabon',
  'Gambia',
  'Georgia',
  'Germany',
  'Ghana',
  'Gibraltar',
  'Greece',
  'Greenland',
  'Grenada',
  'Guadeloupe',
  'Guatemala',
  'Guernsey',
  'Guinea',
  'Guinea-Bissau',
  'Guyana',
  'Haiti',
  'Honduras',
  'Hong Kong SAR',
  'Hungary',
  'Iceland',
  'India',
  'Indonesia',
  'Iraq',
  'Ireland',
  'Isle of Man',
  'Israel',
  'Italy',
  'Jamaica',
  'Japan',
  'Jersey',
  'Jordan',
  'Kazakhstan',
  'Kenya',
  'Kiribati',
  'Kosovo',
  'Kuwait',
  'Kyrgyzstan',
  'Laos',
  'Latvia',
  'Lebanon',
  'Lesotho',
  'Liberia',
  'Libya',
  'Liechtenstein',
  'Lithuania',
  'Luxembourg',
  'Macao SAR',
  'Madagascar',
  'Malawi',
  'Malaysia',
  'Maldives',
  'Mali',
  'Malta',
  'Martinique',
  'Mauritania',
  'Mauritius',
  'Mayotte',
  'Mexico',
  'Moldova',
  'Monaco',
  'Mongolia',
  'Montenegro',
  'Montserrat',
  'Morocco',
  'Mozambique',
  'Myanmar (Burma)',
  'Namibia',
  'Nauru',
  'Nepal',
  'Netherlands',
  'New Caledonia',
  'New Zealand',
  'Nicaragua',
  'Niger',
  'Nigeria',
  'Niue',
  'Norfolk Island',
  'North Macedonia',
  'Norway',
  'Oman',
  'Pakistan',
  'Palestinian Territories',
  'Panama',
  'Papua New Guinea',
  'Paraguay',
  'Peru',
  'Philippines',
  'Pitcairn Islands',
  'Poland',
  'Portugal',
  'Qatar',
  'Réunion',
  'Romania',
  'Russia',
  'Rwanda',
  'Samoa',
  'San Marino',
  'São Tomé and Príncipe',
  'Saudi Arabia',
  'Senegal',
  'Serbia',
  'Seychelles',
  'Sierra Leone',
  'Singapore',
  'Sint Maarten',
  'Slovakia',
  'Slovenia',
  'Solomon Islands',
  'Somalia',
  'South Africa',
  'South Georgia and South Sandwich Islands',
  'South Korea',
  'South Sudan',
  'Spain',
  'Sri Lanka',
  'St. Barthélemy',
  'St. Helena',
  'St. Kitts and Nevis',
  'St. Lucia',
  'St. Martin',
  'St. Pierre and Miquelon',
  'St. Vincent and Grenadines',
  'Sudan',
  'Suriname',
  'Svalbard and Jan Mayen',
  'Sweden',
  'Switzerland',
  'Taiwan',
  'Tajikistan',
  'Tanzania',
  'Thailand',
  'Timor-Leste',
  'Togo',
  'Tokelau',
  'Tonga',
  'Trinidad and Tobago',
  'Tristan da Cunha',
  'Tunisia',
  'Turkey',
  'Turkmenistan',
  'Turks and Caicos Islands',
  'Tuvalu',
  'U.S. Outlying Islands',
  'Uganda',
  'Ukraine',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Uruguay',
  'Uzbekistan',
  'Vanuatu',
  'Vatican City',
  'Venezuela',
  'Vietnam',
  'Wallis and Futuna',
  'Western Sahara',
  'Yemen',
  'Zambia',
  'Zimbabwe',
];

class CustomerAddressEdit extends StatefulWidget {
  final Map address;

  const CustomerAddressEdit({super.key, required this.address});

  @override
  State<CustomerAddressEdit> createState() => _CustomerAddressEditState();
}

class _CustomerAddressEditState extends State<CustomerAddressEdit> {
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final Map _addressSavedFields = {};
  bool _fetchingPinCode = false;
  bool _fetchingPhone = false;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  String _countryCode = '+91';
  late final Map<String, TextEditingController> _controllers;

  void setPhoneNumber(String number) {
    if (number.startsWith(_countryCode)) {
      _phoneController.text = number;
    } else {
      _phoneController.text = _countryCode + number;
    }

    _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length));
  }

  Future<void> _editAddress() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() => _loading = true);
      _formKey.currentState!.save();

      final client = GraphQLProvider.of(context).value;
      final prefs = await SharedPreferences.getInstance();
      final customerEncoded = prefs.getString('customer');

      if (customerEncoded == null) {
        throw Exception('No customer data found');
      }

      final customer = jsonDecode(customerEncoded);
      final accessToken = customer['accessToken'];

      final result = await client.mutate(MutationOptions(document: gql(r'''
					mutation customerAddressUpdate($accessToken: String! $id: ID! $address: MailingAddressInput!) {
						customerAddressUpdate (customerAccessToken: $accessToken id: $id address: $address) {
							customerUserErrors {
								code
								field
								message
							}
						}
					}
				'''), variables: {
        'accessToken': accessToken,
        'id': widget.address['id'],
        'address': {
          'firstName': _addressSavedFields['First name'],
          'lastName': _addressSavedFields['Last name'],
          'company': _addressSavedFields['Company'],
          'address1': _addressSavedFields['Flat/Building Name'],
          'address2': _addressSavedFields['Area/Street'],
          'city': _addressSavedFields['City'],
          'country': _addressSavedFields['Country'],
          'province': _addressSavedFields['State'],
          'zip': _addressSavedFields['Postal/Zip code'],
          'phone': _addressSavedFields['Phone'],
        }
      }));
      if (result.hasException) {
        throw result.exception!;
      }

      final errors = result.data!['customerAddressUpdate']['customerUserErrors'];
      if (errors.isNotEmpty) {
        throw Exception(errors[0]['message']);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully!'))
        );
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  String? getInitialValueEditAddress(String field) {
    switch (field) {
      // case 'First name': return widget.address['firstName'];
      // case 'Last name': return widget.address['lastName'];
      case 'Company':
        return widget.address['company'];
      case 'Flat/Building Name':
        return widget.address['address1'];
      case 'Area/Street':
        return widget.address['address2'];
      case 'City':
        return widget.address['city'];
      case 'Country':
        return widget.address['country'];
      case 'State':
        return widget.address['province'];
      case 'Postal/Zip code':
        return widget.address['zip'];
      // case 'Phone': return widget.address['phone'];
      default:
        return '';
    }
  }

  String? getValueEditAddress(String field) {
    switch (field) {
      case 'First name':
        return widget.address['firstName'];
      case 'Last name':
        return widget.address['lastName'];
      // case 'Company': return widget.address['company'];
      // case 'Flat/Building Name': return widget.address['address1'];
      // case 'Area/Street': return widget.address['address2'];
      // case 'City': return widget.address['city'];
      // case 'Country': return widget.address['country'];
      // case 'State': return widget.address['province'];
      // case 'Postal/Zip code': return widget.address['zip'];
      case 'Phone':
        return widget.address['phone'];
      default:
        return '';
    }
  }

  bool _isValidPostalCode(String postalCode) {
    // Basic postal code validation - can be adjusted based on your requirements
    final postalCodeRegExp = RegExp(r'^[A-Z0-9\s-]{3,10}$');
    return postalCodeRegExp.hasMatch(postalCode.toUpperCase());
  }
  Widget _buildAddressField(String field) {
    if (field == 'Country') {
      return Column(
        children: [
          Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                debugPrint(textEditingValue.text.toLowerCase());

                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return countries.where((String country) {
                  return country.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              initialValue: TextEditingValue(text: getInitialValueEditAddress(field) ?? ''),
              fieldViewBuilder: ((context, textEditingController, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onEditingComplete: onFieldSubmitted,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: field,
                      hintText: 'Country',
                      labelStyle: const TextStyle(color: Colors.black)),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your $field';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _addressSavedFields[field] = value;
                    });
                  },
                );
              }),
              onSelected: (String value) {
                setState(() {
                  _addressSavedFields[field] = value;
                });
              }
          ),
          const SizedBox(height: 12),
        ],
      );
    } else {
      return Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.name,
            // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[a-z A-Z]')),
            // ],
            autofocus: field == 'First name',
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelText: field,

                labelStyle: const TextStyle(color: Colors.black)),
            initialValue: getInitialValueEditAddress(field),
            validator: (value) {
              if (field == 'Company') {
                return null; // Company is optional
              }
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your ${field.toLowerCase()}';
              }
              if (field == 'Postal/Zip code' && !_isValidPostalCode(value)) {
                return 'Please enter a valid postal/zip code';
              }
              return null;
            },
            // validator: (value) {
            // 	if (field == 'First name' || field == 'Company' || field  == 'Phone' || field == 'Area/Street') {
            // 		return null;
            // 	} else {
            // 		if (value == null || value.isEmpty) {
            // 			return 'Please enter your $value';
            // 		}
            // 	}
            // 	return null;
            // },
            onSaved: (value) {
              setState(() {
                _addressSavedFields[field] = value;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
      );
    }
  }
  Widget _buildContactField(String field) {
    if (field == 'phone') {
      return Column(
        children: [
          Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                debugPrint(textEditingValue.text.toString());

                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return contactFields.where((String phone) {
                  return phone.contains(textEditingValue.text);
                });
              },
              initialValue: TextEditingValue(
                  text: getInitialValueEditAddress(field) ?? ''),
              fieldViewBuilder: ((context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onEditingComplete: onFieldSubmitted,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: field,
                      hintText: 'Phone',
                      labelStyle: const TextStyle(color: Colors.black)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your $field';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _addressSavedFields[field] = value;
                    });
                  },
                );
              }),
              onSelected: (String value) {
                setState(() {
                  _addressSavedFields[field] = value;
                });
              }),
          const SizedBox(height: 12),
        ],
      );
    } else {
      return Column(
        children: [
          TextFormField(
            autofocus: field == 'phone',
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                labelText: field,
                labelStyle: const TextStyle(color: Colors.black)),
            initialValue: getValueEditAddress(field),
            validator: (value) {
              // First ensure the value isn't null or empty for all fields
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your ${field.toLowerCase()}';
              }

              // Additional validation based on field type
              switch (field) {
                case 'Phone':
                  // Basic phone validation - requires at least 10 digits
                  String cleanPhone =
                      value.trim().replaceAll(RegExp(r'\s+'), '');

                  if (!cleanPhone.startsWith('+91')) {
                    return 'Phone number must start with +91';
                  }
                  final phoneRegExp = RegExp(r'^\+91[0-9]{10}$');
                  if (!phoneRegExp.hasMatch(cleanPhone)) {
                    return 'Please enter a valid 10-digit number after +91';
                  }
                  break;

                case 'First name':
                case 'Last name':
                  // Name validation - only letters, spaces, and hyphens allowed
                  final nameRegExp = RegExp(r"^[a-zA-Z\s-]+$");
                  if (!nameRegExp.hasMatch(value)) {
                    return 'Please enter a valid ${field}';
                  }
                  // Check minimum length
                  if (value.trim().length < 2) {
                    return '${field.split(" ")[0]} must be at least 2 characters';
                  }
                  break;
              }

              return null;
            },
            onSaved: (value) {
              setState(() {
                _addressSavedFields[field] = value;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var field in [...addressFields, ...contactFields])
        field: TextEditingController(
            text: getInitialValueEditAddress(field) ?? getValueEditAddress(field)
        )
    };
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0, // Prevents elevation change on scroll
        shadowColor: Colors.transparent, // Removes shadow when scrolling
        surfaceTintColor: Colors.transparent, // Removes surface tint effect
        elevation: 0,
        title: const Text('Edit address'),
      ),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 270, 10),
                  child: const Text(
                    'Contact Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                for (String field in contactFields) _buildContactField(field),

                Divider(
                  height: 5,
                  color: Colors.grey[200],
                  thickness: 3,
                ),

                // Address Information Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 270, 10),
                  child: const Text(
                    'Address Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                for (String field in addressFields) _buildAddressField(field),

                const SizedBox(height: 20),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _editAddress();
                        }
                      },
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
                              'Change Address',
                              style: TextStyle(fontSize: 16),
                            )),
                ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Cancel')),
                ),
              ],
            ),
          )),
    );
  }
  Widget _buildPhoneInputField() {
  	return Container(
  		decoration: BoxDecoration(
  			borderRadius: BorderRadius.circular(12),
  			border: Border.all(color: Colors.grey[300]!),
  			color: Colors.grey[50],
  		),
  		child: InternationalPhoneNumberInput(
  			onInputChanged: (PhoneNumber number) {
  				setState(() {
  					_phoneNumber = number;
  					_countryCode = number.dialCode ?? '+91';
  					setPhoneNumber(number.phoneNumber ?? '');
  				});
  			},
  			selectorConfig: const SelectorConfig(
  				selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
  				setSelectorButtonAsPrefixIcon: true,
  				leadingPadding: 16,
  			),
  			inputDecoration: InputDecoration(
  				border: InputBorder.none,
  				hintText: 'Phone Number',
  				hintStyle: TextStyle(color: Colors.grey[600]),
  			),
  			initialValue: _phoneNumber,
  		),
  	);
  }
}
