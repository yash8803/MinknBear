import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contact.dart';
import '../main.dart';

class PrivacyPolicyPage extends StatelessWidget {
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
          'Privacy Policy',
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
                    'At ${dotenv.env['STORE_NAME']!} , safeguarding your privacy is our top priority. This Privacy Policy is crafted to provide you with insights into how we manage your information.',
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
              _buildSectionTitle('Returns & Exchanges'),
              _buildSectionText(
                'At ${dotenv.env['STORE_NAME']!}  we strive to provide top-quality products to our customers. However, we recognize that issues may arise, and we are committed to ensuring customer satisfaction. Below are our return, exchange, and refund policies:',

              ),
              SizedBox(height: 20),
              _buildSectionTitle('Have Questions? We are Here to Assist!'),
              _buildSectionText(
                  'If you have any questions or need further clarification about our Privacy Policy, please dont hesitate to reach out to us at care.minknbear@gmail.com. We are always here to assist you.'),
              SizedBox(height: 10),
              _buildSectionTitle('Our Emphasis: Online Privacy'),
              _buildSectionText(
                  'This Privacy Policy specifically addresses our online activities and how we collect and share information through our website, minknbear.com. Please note that it does not cover information collected offline or through other channels. We may update this policy periodically, so be sure to check back to stay informed.'),
              SizedBox(height: 10),
              _buildSectionTitle('Your Consent Matters'),
              _buildSectionText(
                  'By using our website, you agree to this Privacy Policy and consent to the way we handle your information.'),
              SizedBox(height: 10),
              _buildSectionTitle('What Information Do We Gather?'),
              _buildSectionText(
                  'We may request personal information, and we will always be transparent about why we need it when we ask. If you directly contact us, we may collect additional information like your name, email, and the content of your message or any attachments. If you create an account with us, we may request your contact details such as your name and email.'),
              SizedBox(height: 10),
              _buildSectionTitle('How We Utilize Your Information'),
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
            <p>We use your information for various purposes:</p>
            <ul>
            <li>Operating and enhancing our website.</li>
            <li>Personalizing your experience.</li>
                    <li>Gaining insight into how you use our site.</li>  

<li>Developing new features and products.</li>

        <li>   Keeping you informed through email.</li>
  </ul>
            </div>
        </body>
        </html>"""),
              _buildSectionTitle('Log Files'),
              _buildSectionText(
                  'Similar to many other websites, we use log files to collect information like IP addresses, browser types, timestamps, and more. This data helps us analyze trends, manage the site, and understand how users navigate through it. Rest assured, this information cannot be linked to your personal identity.'),
              SizedBox(height: 10),
              _buildSectionTitle('Cookies and Web Beacons'),
              _buildSectionText(
                  'We use cookies to store information about your preferences and the pages you visit on our site. This allows us to tailor your experience based on your browser type and other details. '),
              SizedBox(height: 10),
              _buildSectionTitle('Third-party Advertising Partners'),
              _buildSectionText(
                  'On occasion, our advertisers may use cookies and web beacons on our website. Each advertiser has its own Privacy Policy, and you can find links to their policies for your reference.'),
              SizedBox(height: 10),
              _buildSectionTitle('Third-Party Privacy Policies'),
              _buildSectionText(
                  'Please be aware that our Privacy Policy does not extend to other advertisers or websites. To learn more about their practices and discover how to opt out of certain options, its advisable to check their respective Privacy Policies. '),
              SizedBox(height: 10),
              _buildSectionTitle('Cookie Management'),
              _buildSectionText(
                  'You can manage cookies through your browser settings. Each web browser has its own approach to handling cookies, so consult your browsers website for detailed information. '),
              SizedBox(height: 10),
              _buildSectionTitle('Changes to Privacy Policy'),
              _buildSectionText(
                  'We may update our Privacy Policy as needed, with any changes taking effect immediately upon posting on our website. We recommend periodically reviewing our website and this policy to stay informed. '),
              SizedBox(height: 10),
              _buildSectionTitle('Get in Touch'),
              _buildSectionText(
                  'For any inquiries or assistance, our customer support team is at your service. Feel free to reach out to us at care.minknbear@gmail.com.'),
            ],
          ),
          SizedBox(height: 20),
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
                    'We deeply value your privacy and are committed to its protection. Thank you for trusting Mink & Bear ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
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
          fontSize: 16,

        ),
      ),
    );
  }
}
