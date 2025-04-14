import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contact.dart';
import '../main.dart';

class RefundPolicyPage extends StatelessWidget {
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
            'Returns & Refunds',
            // dotenv.env['STORE_NAME']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.grey[200],
                  margin: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Returns,Exchange & Refunds',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Thank you for choosing ${dotenv.env['STORE_NAME']!} as your preferred shopping destination. We are committed to ensuring your complete satisfaction with our products. Please take a moment to familiarize yourself with our return and exchange policy.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildSectionTitle('Returns & Exchanges'),
                Text(
                  'At ${dotenv.env['STORE_NAME']!}  we strive to provide top-quality products to our customers. However, we recognize that issues may arise, and we are committed to ensuring customer satisfaction. Below are our return, exchange, and refund policies:',
                  style: TextStyle(fontSize: 16,color: Colors.black54),
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Returns'),
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
              padding: 5px;
              background: #fff;
              border-radius: 8px;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          }
          .heading {
              font-weight: bold;
              font-size: 16px;
              margin-bottom: 2px;
              color: #ea431f;
          }
          ul {
              padding-left: 20px;
          }
            
          .footer {
              margin-top: 5px;
              font-size: 14px;
              color: #555;
          }
            </style>
        </head>
        <body>
            <div class="container">
            <ul>
            <li>Returns are accepted within <span class="heading">72 hours (3 days)</span> of your purchase to maintain our inventory freshness and ensure prompt availability for other customers.</li>
            <li>Mink & Bear will arrange your pickup within 2-3 business days of your request. To facilitate an efficient return process, please make sure all products are <span class="heading">unused, unwashed, and returned in their original packaging with tags intact.</span></li>
            <li>Refunds will be processed within 5-7 business days after we receive your returned items.</li>
            <li>Refunds will be issued to the original payment method used for your purchase, with a deduction of ₹100 for brand safety against fraud.*</li>
            <li>*For refunds, please visit our policy page for detailed information.</li>
            </ul>
            </div>
        </body>
        </html>"""),
                // _buildSectionContent('Returns are accepted within 72 hours (3 days) of your purchase to maintain our inventory freshness and ensure prompt availability for other customers.Mink & Bear will arrange your pickup within 2-3 business days of your request. To facilitate an efficient return process, please make sure all products are unused, unwashed, and returned in their original packaging with tags intact.Refunds will be processed within 5-7 business days after we receive your returned items.Refunds will be issued to the original payment method used for your purchase, with a deduction of ₹100 for brand safety against fraud.* *For refunds, please visit our policy page for detailed information'),
                _buildSectionTitle('Damaged or Incorrect Product'),
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
              margin-bottom: 10px;
              color: #ea431f;
          }
          ul {
              padding-left: 20px;
          }
            
          .footer {
              margin-top: 10px;
              font-size: 14px;
              color: #555;
          }
            </style>
        </head>
        <body>
            <div class="container">
            <ul>
            <li>In case you receive a Damaged / Defective / Wrong / Missing product, we should be notified within 48 hours of delivery. We request you to email us a <span class="heading">Video of the Damaged / Defective / Wrong / Missing product.</span> In case you fail to inform us about the same, the return might not be processed.</li>
        <li>Upon receiving your email, we will verify your request and provide a solution. We will promptly arrange to pick up the damaged items from Mink & Bear and offer a refund or exchange for your purchase.</li>
            </ul>
            </div>
        </body>
        </html>"""),
                _buildSectionTitle('Exchange Policy'),
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
              margin-bottom: 10px;
              color: #ea431f;
          }
          ul {
              padding-left: 20px;
          }
            
          .footer {
              margin-top: 10px;
              font-size: 14px;
              color: #555;
          }
            </style>
        </head>
        <body>
            <div class="container">
        <p>You can effortlessly exchange it within 48 hours of delivery without any extra charges if the product is incorrect or damaged. However, if the product is correct but you're unhappy with the color or size, we will process an exchange upon request with a minimal fee of ₹100 to ensure protection against fraud. </p>  
         <ul>
         <li>Return/Exchange requests must be initiated within 36 hours of the product's delivery.</li>
            <li>Return/Exchange requests must be initiated within 36 hours of the product's delivery.</li>
            <li>Mink & Bear will arrange your pickup within 2-3 business days of your request. To facilitate an efficient return process, please make sure all products are <span class="heading">unused, unwashed, and returned in their original packaging with tags intact.</span></li>
            <li>If your order doesn’t meet the conditions listed above, the exchange request will be declined, and the item will be sent back to your pickup address.</li>
            <li><span class="heading">If the requested size is unavailable for an exchange</span>, you can initiate a refund request, which will be processed according to our refund policy. Please note that no other item can be exchanged for the original product.</li>
            <li>The courier company will attempt to pick up the shipment twice. If they are unable to do, There's no need to worry in this situation; we suggest contacting Mink & Bear by emailing care.minknbear@gmail.com. We will definitely resolve your issue.</li>
            <li>Please note that only one exchange is permitted per order.</li>
            </ul>
            </div>
        </body>
        </html>"""),
                _buildSectionTitle('Cancellation of Orders'),
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
              margin-bottom: 10px;
              color: #ea431f;
          }
          ul {
              padding-left: 20px;
          }
            
          .footer {
              margin-top: 10px;
              font-size: 14px;
              color: #555;
          }
            </style>
        </head>
        <body>
            <div class="container">
            <ul>
            <li>Yes, we can assist with canceling your prepaid order. Please contact us for support.</li>
        <li> Cash on Delivery (COD) orders can be canceled within 24 hours of placement by emailing us at care.minknbear@gmail.com </li>
            <li>By placing an order, the customer agrees not to dispute Mink & Bear's decision and accepts our judgment regarding cancellations.</li>
            </ul>
            </div>
        </body>
        </html>"""),
                _buildSectionTitle('Non-acceptance of Exchanges'),
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
              margin-bottom: 10px;
              color: #ea431f;
          }
          ul {
              padding-left: 20px;
          }
            
          .footer {
              margin-top: 10px;
              font-size: 14px;
              color: #555;
          }
            </style>
        </head>
        <body>
            <div class="container">
            <p>To minimize returns and exchanges, please ensure you check the material and color of the dress. We highly recommend thoroughly reading the product description and reviewing all images before making a purchase. If you have any questions, feel free to reach out for more details about the product. Please note that exchanges and returns will not be accepted for the following reasons:</p>
            <ul>
            <li>Exchanges/Returns are not accepted for products that have been washed or worn.</li>
            <li>Products purchased from the SALE section are not eligible for returns or exchanges.
           </li>
        <li> Cash on Delivery (COD) orders can be canceled within 24 hours of placement by emailing us at care.minknbear@gmail.com</li>    </ul>
            </div>
        </body>
        </html>"""),
                SizedBox(height: 20),

              ])  ,
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
        ));


  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,2,5,2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


}