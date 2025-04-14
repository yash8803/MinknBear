import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contact.dart';
import '../main.dart';

class ShippingPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: seedColor,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Shipping Policy',
            // dotenv.env['STORE_NAME']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(
              color: Colors.grey[200],
              margin: const EdgeInsets.all(5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'At ${dotenv.env['STORE_NAME']!} ,we prioritize delivering an exceptional shopping experience, and efficient shipping is at the heart of it. Please take a moment to familiarize yourself with our shipping and delivery policies.',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Collaboration with Reputable Partners'),
                _buildSectionText(
                  ' ${dotenv.env['STORE_NAME']!}   collaborates with trusted transport and courier agencies to ensure the swift delivery of your orders. However, its crucial to note that Mink & Bear cannot be held responsible for any delays caused by incomplete or inaccurate address information.',
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Delivery Timeframes'),
                _buildSectionText(
                    'Our commitment is to deliver your orders within approximately 4-6 working days from the date of shipment. All orders are dispatched using reliable carriers and will be delivered directly to your doorstep.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Shipping Address'),
                _buildSectionText(
                    'To ensure timely delivery, please provide a complete and accurate shipping address, including the postal code or zip code. The billing address should match the one where you receive your credit card statements, while the shipping address is where we will deliver your order.'),
                const SizedBox(height: 10),
                _buildSectionTitle(
                    'Customer Responsibility for Shipping Charges'),
                Html(data: """<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Discount Offers</title>
            <style>
          body {
              font-family: Arial, sans-serif;
              line-height: 1.2;
              background-color: #f9f9f9;
              color: #333;
          }
          .container {
              padding: 10px;
              background: #fff;
              border-radius: 8px;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          }
          .heading {
              font-weight: bold;
              font-size: 16px;
              color: #ea431f;
          }
          ul {
              padding-left: 15px;
          }
            
         
            </style>
        </head>
        <body>
            <div class="container">
            <ul>
            <li>We recommend recording a video when you file your claim for the order.</li>
            <li>In case you receive a Damaged / Defective / Wrong / Missing product, we should be notified within 24 hours of delivery. We request you to email us a Video of the Damaged / Defective / Wrong / Missing product.</li>

<li>Developing new features and products.</li>

        <li>   Keeping you informed through email.</li>
  </ul>
            </div>
        </body>
        </html>"""),
                const SizedBox(height: 10),
                _buildSectionTitle('Preferred Courier Partners'),
                _buildSectionText(
                    'Mink & Bear relies on esteemed transport and courier agencies, including Blue Dart, DHL, Fedex, EcomExpress, Delhivery, Xpressbees, DTDC, and Dotzot. These agencies typically deliver within 48-72 hours to major cities in India.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Alternate Shipping Options'),
                _buildSectionText(
                    'For alternative shipping options, especially for large merchandise orders, contact us at care.minknbear@gmail.com. Upon request, we may provide special quotes for shipping.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Split Shipments'),
                _buildSectionText(
                    'All Mink & Bear products are shipped from India.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Refund and Returns Due to Shipping Delays'),
                _buildSectionText(
                    'Mink & Bear does not issue refunds, returns, replacements, or exchanges solely due to shipping delays. However, at our discretion, store credit may be offered for future orders.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Delay Notification'),
                _buildSectionText(
                    'In case of order delays due to stock unavailability or unforeseen issues, Mink & Bear will promptly notify you via email.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Shipment Time'),
                _buildSectionText(
                    'The estimated shipment time displayed on our website is indicative and subject to change. For a more accurate estimate, contact us via email with your order number or item codes. '),
                const SizedBox(height: 10),
                _buildSectionTitle('Transit Risk'),
                _buildSectionText(
                    'All orders are fully insured at no extra cost to our customers. In the rare event of a lost order during transit, Mink & Bear will initiate the reprocessing of the order. However, we are not responsible for lost packages or damages post-delivery.'),
                const SizedBox(height: 10),
                _buildSectionTitle('Tracking Your Shipment'),
                _buildSectionText(
                    'Mink & Bear provides shipment details via email alerts once the package is handed over to the carrier agency. Please note that tracking numbers may take up to 24 business hours to become active.'),
                _buildSectionTitle('Request for Address Change'),
                _buildSectionText(
                    'If you need to change your shipping address, make the request within 24 hours of placing your order by emailing us at care.minknbear@gmail.com.'),
                _buildSectionTitle('Ready to Ship Section'),
                _buildSectionText(
                    'Explore our Ready to Ship Section for last-minute orders, ensuring delivery within the next 4-6 business working days.'),
                _buildSectionTitle('Delays'),
                _buildSectionText(
                    'While we strive to meet shipment timeframes, occasional delays may occur due to unforeseen circumstances. In such cases, we may offer benefits such as store credit for future orders or free gifts on a case-by-case basis.'),
              ],
            ),
            const SizedBox(height: 20),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'care.minknbear@gmail.com',
              query:
                  'subject=Support Request&body=Hi, I need help with...', // Optional
            );

            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not launch email app'),
                ),
              );
            }
          },
          label: const Text(
            'Need Help?',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.mail,
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
