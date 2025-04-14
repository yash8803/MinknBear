import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconify_flutter/icons/zondicons.dart'; // for Non Colorful Icons

import '../contact.dart';
import '../main.dart';

class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: seedColor,
          elevation: 0,
          scrolledUnderElevation: 2,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Terms And Conditions',
            // dotenv.env['STORE_NAME']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(
              color: Colors.grey[200],
              margin: EdgeInsets.all(5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thank you for choosing ${dotenv.env['STORE_NAME']!} as your ultimate destination for exquisite fashion. We are dedicated to providing you with top-quality products, cutting-edge styles, and a seamless shopping experience. Mink & Bear proudly operates its e-commerce website at www.minknbear.com.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _buildSectionTitle('Our Core Focus: Meeting Your Fashion Desires'),
                _buildSectionText(
                  'At ${dotenv.env['STORE_NAME']!}, we take pride in offering a diverse range of goods to our esteemed customers. Please be aware that our product offerings are intended for individual end-users, and we sell our products in standard household quantities. These terms and conditions apply to all contracts entered into through www.minknbear.com, governing all general business interactions between Mink & Bear and our valued customers. We do not accept any alternative third-party terms and conditions unless explicitly stated otherwise.',
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Usage Policy'),
                _buildSectionText(
                    'Upon registering as a customer with Mink & Bear, you will be required to provide personal information. It is your responsibility to ensure that the information you provide is accurate and complete. After successfully completing the registration process, you will receive a confirmation email, granting you access to our online services. At this stage, you will also receive a unique ID and password. Please exercise caution and maintain the confidentiality and security of your ID, password, and any other access data, guarding them against unauthorized access. Mink & Bear reserves the right to reject registrations without providing specific reasons.'),
                _buildSectionText('By transmitting content to Mink & Bear, you grant us exclusive and unrestricted rights to use the content, including its transfer to third parties, for publication and distribution, either in full or in part, on www.minknbear.com or through other means. Mink & Bear retains the discretion to store, release, modify, or correct content as needed.'),
                _buildSectionText('It is prohibited to use www.minknbear.com in a manner that disrupts or manipulates technical processes or seeks to gain unjust advantages at the expense of Mink & Bear or other members. Such actions will lead to the immediate revocation of purchasing rights on Mink & Bear and the termination of your customer account.'),
                _buildSectionText('Please note that only one membership account per individual is permitted. Multiple registrations will be deleted by Mink & Bear.'),
                _buildSectionText('In the password-protected area of www.minknbear.com, you can access information related to your recent orders and manage or update your personal data and newsletter subscriptions.'),
                _buildSectionText('Mink & Bear reserves the right to issue warnings, terminate memberships, or modify or delete user-submitted content in cases of violations of these provisions. Any claims for damages by Mink & Bear remain unaffected.'),
                SizedBox(height: 10),
                _buildSectionTitle('Contractual Partners, Language, and Contract Conclusion'),
                _buildSectionText(
                    'When you engage in contracts on www.minknbear.com, your exclusive contractual partner is Mink & Bear. www.minknbear.com operates exclusively in the English language, and contracts concluded through our platform are conducted solely in English. Upon placing an order and clicking "order" or "buy now," you are making a legally binding contract offer. After submitting your order, you will receive a confirmation email from Mink & Bear. Please note that this confirmation email does not constitute acceptance of the contract. Contract acceptance occurs when the goods are dispatched. In cases involving orders with multiple items, contract acceptance applies only to the items that are actually shipped.'),
                _buildSectionText('In instances where prices are incorrectly displayed on www.minknbear.com due to technical errors, Mink & Bear reserves the right to void the transaction. The burden of proof regarding the error rests with Mink & Bear, and any payments already made will be promptly refunded.'),
                SizedBox(height: 10),
                _buildSectionTitle('Prices and Shipping Fees'),
                _buildSectionText(
                    'The prices listed on the product page at the time of your order on www.minknbear.com are applicable to your order. These prices do not include taxes, and the final price, inclusive of taxes, will be displayed on the shopping cart page.'),
                SizedBox(height: 10),
                _buildSectionTitle('Payment Methods'),
                _buildSectionText(
                    'Mink & Bear offers a variety of payment methods, including credit cards, debit cards, net banking, and Cash on Delivery (COD). Mink & Bear reserves the right to exclude specific payment methods for individual products and may recommend alternative payment methods as necessary.'),
                _buildSectionText('We accept a range of credit cards, including Visa, American Express, and MasterCard. Mink & Bear will charge your credit card immediately upon receiving and dispatching your order.'),
                SizedBox(height: 10),
                _buildSectionTitle('Shipping'),
                _buildSectionText(
                    'Products will be shipped to the shipping address provided by the customer. It is the customer responsibility to ensure that delivery is feasible during regular working hours.'),
                _buildSectionText('Mink & Bear endeavors to adhere to specified delivery timelines for each product. While we strive for prompt order shipments, certain products may have longer delivery times due to availability.'),
                _buildSectionText('Mink & Bear assumes no sourcing risk, particularly for purchases based on product descriptions. We are obligated to ship from existing stock or stock ordered from suppliers.'),
                _buildSectionText('In cases of force majeure, the shipping duration may be reasonably extended. Force majeure events include strikes, official interventions, energy or resource shortages, and business disruptions such as machinery damage from fire or water, lightning strikes, or unforeseeable business complications for which Mink & Bear cannot be held accountable. Any commencement and conclusion of such shipping delays will be promptly communicated by Mink & Bear.'),
                _buildSectionText('Mink & Bear reserves the right to cancel the contract if delivery fails due to the customer fault. Payments already made will be refunded, or store credit will be issued, depending on the circumstances.'),
                _buildSectionText('We kindly request that you promptly report any obvious transport damage to the delivery personnel and Mink & Bear. This action does not affect your warranty rights but assists Mink & Bear in making claims against suppliers.'),
                _buildSectionText('All stated delivery times apply following order confirmation from Mink & Bear. For Cash on Delivery orders, this confirmation occurs after we have called and confirmed the order from your end. If the customer does not confirm the order after this, Mink & Bear reserves the discretion to cancel the order.'),
                _buildSectionText('For detailed information regarding our return policies, please refer to our Delivery and Returns section.'),
                SizedBox(height: 10),
                _buildSectionTitle('Retention of Title'),
                _buildSectionText('Ownership of goods is transferred to the member upon full payment.'),
                SizedBox(height: 10),
                _buildSectionTitle('Liabilities'),
                _buildSectionText('Mink & Bear holds liability solely for intentional and gross negligence unless concealed damages, damages involving loss of life, limb, or health, or damage resulting from the infringement of essential contractual obligations are proven. The same applies to violations by Mink & Bear agents.'),
                SizedBox(height: 10),
                _buildSectionTitle('Service and Complaints'),
                _buildSectionText('Customer satisfaction is of utmost importance at Mink & Bear. We are committed to addressing your concerns as promptly as possible and providing feedback following your input. For service inquiries, please reach out to our customer service department at care.minknbear@gmail.com.'),
                SizedBox(height: 10),
                _buildSectionTitle('Data Security'),
                _buildSectionText('When you register as a customer on www.minknbear.com, you will be required to provide personal data necessary for processing contracts concluded on the website. All personal data is handled confidentially and in compliance with relevant legal regulations. We employ cutting-edge encryption techniques through our payment gateways to ensure the security of your privacy in online payment transactions.'),
                SizedBox(height: 10),
                _buildSectionTitle('Image Rights'),
                _buildSectionText('All rights to use imagery on www.minknbear.com belong to Mink & Bear or our partners. The use of this material in any form is prohibited unless explicit permission has been granted by Mink & Bear.'),
                SizedBox(height: 20),
                _buildSectionTitle('Thank you for selecting Mink & Bear.'),

              ],
            ),

          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(

          onPressed: () async {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'care.minknbear@gmail.com',
              query: 'subject=Support Request&body=Hi, I need help with...', // Optional
            );

            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not launch email app'),
                ),
              );
            }
          },
          label: Text('Contact Us',style: TextStyle(color: Colors.white),),
          icon: Icon(Icons.mail,color: Colors.white,),
          backgroundColor: Colors.black,
        )

    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Text(
        title,
        style: TextStyle(
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
        style: TextStyle(
          fontSize: 15,

        ),
      ),
    );
  }
}
