import 'dart:convert' show jsonDecode;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final List<String> addressFields = [
	'Flat/Building Name', 'Area/Street', 'Postal/Zip code', 'City', 'State', 'Country',
];

final List<String> contactFields = [
	'First name', 'Last name', 'Phone'
];

final List<String> countries = [
	'Afghanistan', 'Åland Islands', 'Albania', 'Algeria', 'Andorra', 'Angola',
	'Anguilla', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Aruba',
	'Ascension Island', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas',
	'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize',
	'Benin', 'Bermuda', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina',
	'Botswana', 'Brazil', 'British Indian Ocean Territory', 'British Virgin Islands',
	'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon',
	'Canada', 'Cape Verde', 'Caribbean Netherlands', 'Cayman Islands',
	'Central African Republic', 'Chad', 'Chile', 'China', 'Christmas Island',
	'Cocos (Keeling) Islands', 'Colombia', 'Comoros', 'Congo - Brazzaville',
	'Congo - Kinshasa', 'Cook Islands', 'Costa Rica', 'Croatia', 'Curaçao',
	'Cyprus', 'Czechia', 'Côte d\'Ivoire', 'Denmark', 'Djibouti', 'Dominica',
	'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea',
	'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Falkland Islands',
	'Faroe Islands', 'Fiji', 'Finland', 'France', 'French Guiana',
	'French Polynesia', 'French Southern Territories', 'Gabon', 'Gambia',
	'Georgia', 'Germany', 'Ghana', 'Gibraltar', 'Greece', 'Greenland',
	'Grenada', 'Guadeloupe', 'Guatemala', 'Guernsey', 'Guinea', 'Guinea-Bissau',
	'Guyana', 'Haiti', 'Honduras', 'Hong Kong SAR', 'Hungary', 'Iceland',
	'India', 'Indonesia', 'Iraq', 'Ireland', 'Isle of Man', 'Israel', 'Italy',
	'Jamaica', 'Japan', 'Jersey', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati',
	'Kosovo', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho',
	'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Macao SAR',
	'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Martinique',
	'Mauritania', 'Mauritius', 'Mayotte', 'Mexico', 'Moldova', 'Monaco',
	'Mongolia', 'Montenegro', 'Montserrat', 'Morocco', 'Mozambique',
	'Myanmar (Burma)', 'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Caledonia',
	'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'Niue', 'Norfolk Island',
	'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palestinian Territories',
	'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines',
	'Pitcairn Islands', 'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia',
	'Rwanda', 'Réunion', 'Samoa', 'San Marino', 'Saudi Arabia', 'Senegal',
	'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Sint Maarten',
	'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa',
	'South Georgia & South Sandwich Islands', 'South Korea', 'South Sudan',
	'Spain', 'Sri Lanka', 'St. Barthélemy', 'St. Helena', 'St. Kitts & Nevis',
	'St. Lucia', 'St. Martin', 'St. Pierre & Miquelon', 'St. Vincent & Grenadines',
	'Sudan', 'Suriname', 'Svalbard & Jan Mayen', 'Sweden', 'Switzerland',
	'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo',
	'Tokelau', 'Tonga', 'Trinidad & Tobago', 'Tunisia', 'Turkey', 'Turkmenistan',
	'Turks & Caicos Islands', 'Tuvalu', 'U.S. Outlying Islands', 'Uganda',
	'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States',
	'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam',
	'Wallis & Futuna', 'Western Sahara', 'Yemen', 'Zambia', 'Zimbabwe'
];

class CustomerAddressAdd extends StatefulWidget {
	const CustomerAddressAdd({super.key});

	@override
	State<CustomerAddressAdd> createState() => _CustomerAddressAddState();
}

class _CustomerAddressAddState extends State<CustomerAddressAdd> {
	final _formKey = GlobalKey<FormState>();
	bool _loading = false;
	final Map _addressSavedFields = {};
	bool _fetchingPinCode = false;
	bool _fetchingPhone = false;
	bool _isDefaultAddress = false; // New state variable for default address

	String? _defaultAddressId;
	List? _addresses;
	bool _paginationLoading = false;
	Map? _paginationInfo;
	// Controllers for all form fields
	final TextEditingController _cityController = TextEditingController();
	final TextEditingController _stateController = TextEditingController();
	final TextEditingController _countryController = TextEditingController();
	final TextEditingController _firstNameController = TextEditingController();
	final TextEditingController _lastNameController = TextEditingController();
	final TextEditingController _phoneController = TextEditingController();
	final TextEditingController _buildingController = TextEditingController();
	final TextEditingController _areaController = TextEditingController();
	final TextEditingController _postalCodeController = TextEditingController();


	@override
	void dispose() {
		_cityController.dispose();
		_stateController.dispose();
		_countryController.dispose();
		_firstNameController.dispose();
		_lastNameController.dispose();
		_phoneController.dispose();
		_buildingController.dispose();
		_areaController.dispose();
		_postalCodeController.dispose();
		super.dispose();
	}

	void _resetForm() {
		setState(() {
			_formKey.currentState?.reset();
			_addressSavedFields.clear();
			_cityController.clear();
			_stateController.clear();
			_countryController.clear();
			_firstNameController.clear();
			_lastNameController.clear();
			_phoneController.clear();
			_buildingController.clear();
			_areaController.clear();
			_postalCodeController.clear();
			_loading = false;
			_fetchingPinCode = false;
			_fetchingPhone = false;
			_isDefaultAddress = false; // Reset default address checkbox

		});
	}


	Future<void> _fetchAddressDetails(String pinCode) async {
		if (pinCode.length != 6) return;

		setState(() {
			_fetchingPinCode = true;
		});

		try {
			final response = await http.get(
				Uri.parse('https://api.postalpincode.in/pincode/$pinCode'),
			);

			if (response.statusCode == 200) {
				final List data = jsonDecode(response.body);

				// Check if data is not empty and has the expected structure
				if (data.isNotEmpty &&
						data[0]['Status'] == 'Success' &&
						data[0]['PostOffice'] != null &&
						data[0]['PostOffice'].isNotEmpty) {

					final postOffice = data[0]['PostOffice'][0];

					setState(() {
						_cityController.text = postOffice['District'] ?? '';
						_stateController.text = postOffice['State'] ?? '';
						_countryController.text = postOffice['Country'] ?? '';

						_addressSavedFields['City'] = postOffice['District'] ?? '';
						_addressSavedFields['State'] = postOffice['State'] ?? '';
						_addressSavedFields['Country'] = postOffice['Country'] ?? '';
					});
				} else {
					// Invalid pincode or no data found
					if (mounted) {
						ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(
								content: Text('No address details found for this pincode'),
								duration: Duration(seconds: 2),
							),
						);
					}
					// Clear the fields since no valid data was found
					setState(() {
						_cityController.clear();
						_stateController.clear();
						_countryController.clear();
					});
				}
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Error fetching address details'),
						duration: Duration(seconds: 2),
					),
				);
			}
			// Clear the fields on error
			setState(() {
				_cityController.clear();
				_stateController.clear();
				_countryController.clear();
			});
		} finally {
			setState(() {
				_fetchingPinCode = false;
			});
		}
	}
	Future<void> _setDefaultAddress(String? addressId) async {
		if (addressId == null) return;

		// Ensure the address ID is in the correct Shopify format
		// If it's not already in the format "gid://shopify/MailingAddress/123456"
		if (!addressId.startsWith('gid://')) {
			addressId = 'gid://shopify/MailingAddress/$addressId';
		}

		final client = GraphQLProvider.of(context).value;

		final prefs = await SharedPreferences.getInstance();
		String? customerEncoded = prefs.getString('customer');

		if (customerEncoded == null) {
			return;
		}

		Map customer = jsonDecode(customerEncoded);
		String accessToken = customer['accessToken'];

		// Using the correct Shopify GraphQL mutation
		final result = await client.mutate(MutationOptions(
			document: gql(r'''
      mutation customerDefaultAddressUpdate($customerAccessToken: String!, $addressId: ID!) {
        customerDefaultAddressUpdate(customerAccessToken: $customerAccessToken, addressId: $addressId) {
          customer {
            id
            defaultAddress {
              id
            }
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
				'customerAccessToken': accessToken,
				'addressId': addressId,
			},
			fetchPolicy: FetchPolicy.noCache,
		));

		if (kDebugMode) {
			print('Default address update result: $result');
		}

		if (context.mounted) {
			if (result.hasException) {
				ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
								content: Text('Error setting default address: ${result.exception?.graphqlErrors.first.message ?? "Unknown error"}')
						)
				);
			} else {
				final errors = result.data?['customerDefaultAddressUpdate']['customerUserErrors'] ?? [];

				if (errors.isEmpty) {
					setState(() {
						_defaultAddressId = addressId;
					});

					ScaffoldMessenger.of(context).showSnackBar(
							const SnackBar(content: Text('Default address updated successfully'))
					);
				} else {
					ScaffoldMessenger.of(context).showSnackBar(
							SnackBar(content: Text('Error: ${errors.first['message']}'))
					);
				}
			}
		}
	}
	Future<void> _addNewAddress() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() {
			_loading = true;
		});

		try {
			_formKey.currentState!.save();

			final client = GraphQLProvider.of(context).value;
			client.cache.store.reset();

			final prefs = await SharedPreferences.getInstance();
			String? customerEncoded = prefs.getString('customer');

			if (customerEncoded == null) {
				throw Exception('Customer session not found');
			}

			Map customer = jsonDecode(customerEncoded);
			String accessToken = customer['accessToken'];

			final result = await client.mutate(
					MutationOptions(
						document: gql(r'''
          mutation customerAddressCreate($accessToken: String!, $address: MailingAddressInput!) {
            customerAddressCreate(customerAccessToken: $accessToken, address: $address) {
              customerAddress {
                id
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
							'accessToken': accessToken,
							'address': {
								'firstName': _addressSavedFields['First name'] ?? '',
								'lastName': _addressSavedFields['Last name'] ?? '',
								'company': _addressSavedFields['Company'] ?? '',
								'address1': _addressSavedFields['Flat/Building Name'] ?? '',
								'address2': _addressSavedFields['Area/Street'] ?? '',
								'city': _addressSavedFields['City'] ?? '',
								'province': _addressSavedFields['State'] ?? '',
								'country': _addressSavedFields['Country'] ?? '',

								'zip': _addressSavedFields['Postal/Zip code'] ?? '',
								'phone': _addressSavedFields['Phone'] ?? '',
							}
						},
						fetchPolicy: FetchPolicy.noCache,
					)
			);

			if (!mounted) return;

			if (result.hasException) {
				throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to create address');
			}

			final createData = result.data?['customerAddressCreate'];
			if (createData == null) {
				throw Exception('No data received from server');
			}

			final List errors = createData['customerUserErrors'] ?? [];
			if (errors.isNotEmpty) {
				throw Exception(errors.first['message']);
			}

			final customerAddress = createData['customerAddress'];
			if (customerAddress == null) {
				throw Exception('No address data received');
			}

			// Get the full address ID from the response
			String addressId = customerAddress['id'];

			if (_isDefaultAddress) {
				await _setDefaultAddress(addressId);
			}

			ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Address created successfully'))
			);

			await Future.delayed(const Duration(seconds: 2));
			if (!mounted) return;
			Navigator.of(context).pop(true);

		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text(e.toString()))
			);
		} finally {
			if (mounted) {
				setState(() {
					_loading = false;
				});
			}
		}
	}
	Widget _buildAddressField(String field) {
		if (field == 'Postal/Zip code') {
			return Column(
				children: [
					TextFormField(
						autofocus: true,
						cursorColor: Colors.black,
						keyboardType: TextInputType.phone,
						decoration: InputDecoration(

								border: const OutlineInputBorder(),
								focusedBorder: const OutlineInputBorder(
									borderSide: BorderSide(color: Colors.black),
								),
								labelText: field,
								suffixIcon: _fetchingPinCode
										? const SizedBox(
									height: 20,
									width: 20,
									child: Padding(
										padding: EdgeInsets.all(12.0),
										child: CircularProgressIndicator(strokeWidth: 2),
									),
								)
										: null,
								labelStyle: const TextStyle(color: Colors.black)),

						validator: (value) {
							if (value == null || value.isEmpty) {
								return 'Please enter your $field';
							}
							return null;
						},
						onChanged: (value) {
							_fetchAddressDetails(value);
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
		} else if (field == 'City' || field == 'State' || field == 'Country') {
			return Column(
				children: [
					TextFormField(
						controller: field == 'City'
								? _cityController
								: field == 'State'
								? _stateController
								: _countryController,
						cursorColor: Colors.black,
						decoration: InputDecoration(
								border: const OutlineInputBorder(),
								focusedBorder: const OutlineInputBorder(
									borderSide: BorderSide(color: Colors.black),
								),
								labelText: field,
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
					),
					const SizedBox(height: 12),
				],
			);
		}

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
							fieldViewBuilder: ((context, textEditingController, focusNode, onFieldSubmitted) {
								return TextFormField(
									controller: textEditingController,
									focusNode: focusNode,
									onEditingComplete: onFieldSubmitted,
									cursorColor: Colors.black,
									decoration: InputDecoration(
											border: const OutlineInputBorder(),
											focusedBorder: const OutlineInputBorder(
												borderSide: BorderSide(color: Colors.black),
											),
											labelText:field,
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
						autofocus: field == 'Postal/Zip code',
						cursorColor: Colors.black,
						decoration: InputDecoration(
								border: const OutlineInputBorder(
								),
								focusedBorder: const OutlineInputBorder(
									borderSide: BorderSide(color: Colors.black),
								),
								labelText: field,
								labelStyle: const TextStyle(color: Colors.black)),

						validator: (value) {
							if (field == 'Company' || field  == 'Phone' || field == 'Area/Street') {
								return null;
							} else {
								if (value == null || value.isEmpty) {
									return 'Please enter your $field';
								}
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
	Widget _buildContactField(String field) {
		if (field == 'Phone') {
			return Column(
				children: [
					TextFormField(
						initialValue: '+91',
						autofocus: true,
						cursorColor: Colors.black,
						keyboardType: TextInputType.phone,
						decoration: InputDecoration(

								border: const OutlineInputBorder(),
								focusedBorder: const OutlineInputBorder(
									borderSide: BorderSide(color: Colors.black),
								),
								labelText: field,
								labelStyle: const TextStyle(color: Colors.black)),

						validator: (value) {
							// First ensure the value isn't null or empty for all fields
							if (value == null || value.trim().isEmpty) {
								return 'Please enter your ${field.toLowerCase()}';
							}

							// Additional validation based on field type
							switch (field) {

								case 'Phone':

								// Basic phone validation - requires at least 10 digits
									String cleanPhone = value.trim().replaceAll(RegExp(r'\s+'), '');

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

							return null; // Validation passed
						},
						onChanged: (value) {
							_fetchAddressDetails(value);
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
		} else if (field == 'City' || field == 'State' || field == 'Country') {
			return Column(
				children: [
					TextFormField(
						controller: field == 'City'
								? _cityController
								: field == 'State'
								? _stateController
								: _countryController,
						autofocus: true,
						cursorColor: Colors.black,
						keyboardType: TextInputType.phone,
						decoration: InputDecoration(

								border: const OutlineInputBorder(),
								focusedBorder: const OutlineInputBorder(
									borderSide: BorderSide(color: Colors.black),
								),
								labelText: field,
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
					),
					const SizedBox(height: 12),
				],
			);
		}

		return Column(
			children: [
				TextFormField(
					autofocus: field == 'First name',

					cursorColor: Colors.black,
					keyboardType: TextInputType.multiline,
					decoration: InputDecoration(

							border: const OutlineInputBorder(),
							focusedBorder: const OutlineInputBorder(
								borderSide: BorderSide(color: Colors.black),
							),
							labelText: field,
							labelStyle: const TextStyle(color: Colors.black)),
					validator: (value) {
						if (field == 'Company' || field  == 'Phone' || field == 'Area/Street') {
							return null;
						} else {
							if (value == null || value.isEmpty) {
								return 'Please enter your $field';
							}
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
	Widget _buildDefaultAddressCheckbox() {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 8.0),
			child: Row(
				children: [
					Checkbox(
						value: _isDefaultAddress,
						onChanged: (bool? value) {
							setState(() {
								_isDefaultAddress = value ?? true;
							});
						},
						activeColor: Colors.black,
					),
					const Text(
						'Set as default address',
						style: TextStyle(fontSize: 16),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
				appBar: AppBar(
					scrolledUnderElevation: 0, // Prevents elevation change on scroll
					shadowColor: Colors.transparent, // Removes shadow when scrolling
					surfaceTintColor: Colors.transparent, // Removes surface tint effect
					elevation: 0,
					backgroundColor: Colors.white,
					title: const Text('New Address',
						style: TextStyle(
							fontSize: 20,
							fontWeight: FontWeight.w600,
							color: Colors.black87,
						),),
					actions: [
						Padding(
							padding: const EdgeInsets.only(right: 8),
							child: TextButton.icon(
								onPressed: () async {
									_resetForm();
								},
								icon: const Icon(Icons.refresh, size: 20),
								label: const Text('Reset'),
								style: TextButton.styleFrom(
									foregroundColor: Colors.blueGrey,
									iconColor: Colors.blueGrey,
									textStyle: const TextStyle(fontWeight: FontWeight.w600,),
								),
							),
						),
					],
				),
				body: Form(
					key: _formKey,
					child: SingleChildScrollView(
						padding: const EdgeInsets.fromLTRB(16, 20, 14, 8),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Padding(
									padding: const EdgeInsets.fromLTRB(0,0,250,10),
									child: const Text(
										'Contact Info',
										style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
									),
								),
								for (String field in contactFields)
									_buildContactField(field),

								Divider(height: 5,color: Colors.grey[200],thickness: 3,),

								// Address Information Section
								Padding(
									padding: const EdgeInsets.fromLTRB(0,10,250,10),
									child: const Text(
										'Address Info',
										style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
									),
								),
								for (String field in addressFields)
									_buildAddressField(field),

								_buildDefaultAddressCheckbox(),

								const SizedBox(height: 20),

								// Submit Button
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
												_addNewAddress();
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
											'Save Address',
											style: TextStyle(fontSize: 16),
										),
									),
								),

								const SizedBox(height: 10),

								// Cancel Button
								SizedBox(
									width: double.infinity,
									child: TextButton(
										onPressed: () async {
											await Future.delayed(const Duration(milliseconds: 200));
											if (context.mounted) {
												Navigator.of(context).pop();
											}
										},
										child: const Text('Cancel'),
									),
								),
							],
						),
					),
				)

		);
	}
}

