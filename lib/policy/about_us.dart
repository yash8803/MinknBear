import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contact.dart';
import '../main.dart';

class AboutUsPage extends StatelessWidget {
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
            'About Us',
            // dotenv.env['STORE_NAME']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Welcome to ${dotenv.env['STORE_NAME']!},   where passion meets craftsmanship in every stitch of our clothing for both men and women. Our brand story began with a vision inspired by the elegance of nature. During an enlightening conversation between me and my homie, the idea emerged to blend the luxurious softness of a mink with the rugged, timeless strength of a bear. Thus, Mink & Bear was born—a name that embodies the essence of sophistication and resilience.',
                  style: const TextStyle(fontSize: 16,color: Colors.black87),
                ),
                const SizedBox(height: 20,),
                Text(
                  'At ${dotenv.env['STORE_NAME']!}, we specialize in premium polo t-shirts and high-quality oversized fit tees, all designed to redefine casual elegance. We believe that style should never compromise comfort. Each garment is meticulously crafted from the finest fabrics, ensuring durability and a perfect fit that enhances your everyday experience.',
                  style: const TextStyle(fontSize: 16,color: Colors.black87),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Whether you are enjoying a casual outing, embarking on a weekend adventure, or simply relaxing at home, our versatile collection is designed to seamlessly integrate into your lifestyle while maintaining an effortlessly polished appearance.',
                  style: TextStyle(fontSize: 16,color: Colors.black87),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Our commitment extends beyond creating exceptional clothing; we aspire to cultivate a community that values quality craftsmanship and timeless design. Join us on our journey as we continue to innovate and elevate men’s and women’s fashion, one polo and oversized t-shirt at a time.',
                  style: TextStyle(fontSize: 16,color: Colors.black87),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Discover the essence of Mink & Bear—where comfort meets style, and every detail matters.',
                  style: TextStyle(fontSize: 16,color: Colors.black87),
                ),
                const SizedBox(height: 20),
                RichText(
                    text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        children: [
                          TextSpan(text: "For more information, please visit our "),
                          TextSpan(
                            text: "'Contact'",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: " page at the bottom of the page or reach out to us directly."),
                        ])),
                const SizedBox(height: 50,),

                _buildFooter()
              ])  ,
        ),
 );


  }
  Widget _buildFooter() {
    return Container(
      color: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About The Shop',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mink & Bear specializes in premium polo and oversized t-shirts, blending comfort with elegance. Each piece reflects our commitment to quality, ensuring you look and feel your best for any occasion.',
            style: TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Office Address: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  '152-Silver Business Hub,Bapa Sitaram Chowk,Surat, Gujarat',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.phone,size: 17,color: Colors.grey[600],),
              const SizedBox(width: 5,),

              InkWell(
                child: Text('+91 7405899480', style: TextStyle(color: Colors.grey[600],)),
                onTap: () {
                  launchUrl(Uri.parse('tel:+91 7405899480'));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),  // Changed from 8 to 4
          Row(
            children: [
              Icon(Icons.email_outlined,size: 17,color: Colors.grey[600],),
              const SizedBox(width: 5,),
              InkWell(
                child: Text('care.minknbear@gmail.com', style: TextStyle(color: Colors.grey[600])),
                onTap: () {
                  launchUrl(Uri.parse('mailto:care.minknbear@gmail.com'));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSocialButton('assets/social-icons/facebook.svg'),
              const SizedBox(width: 16),
              _buildSocialButton('assets/social-icons/instagram.svg'),
              const SizedBox(width: 16),
              _buildSocialButton('assets/social-icons/youtube.svg'),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSocialButton(String assetPath) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: SvgPicture.asset(assetPath, width: 20, height: 20),
        onPressed: () {
          if(assetPath=='assets/social-icons/facebook.svg'){
            launchUrl(Uri.parse('https://www.facebook.com/minknbearClothing'));
          }
          if(assetPath=='assets/social-icons/instagram.svg'){
            launchUrl(Uri.parse('https://www.instagram.com/minknbearclothing/'));
          }
          if(assetPath=='assets/social-icons/youtube.svg'){
            launchUrl(Uri.parse('https://www.youtube.com/@MinknBear'));
          }
        },
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,2,5,2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


}