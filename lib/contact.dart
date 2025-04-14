import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shopify_flutter/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import 'contact.dart';

class Contact extends StatefulWidget {

  const Contact({Key? key}) : super(key: key);

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  void _navigateWithSlide(BuildContext context, Widget page) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      Navigator.of(context).push(
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

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: seedColor,
          elevation: 0,
          title: const Text(
            'Contact',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.favorite_outline_outlined,
          //         color: Colors.black87),
          //     onPressed: () => Navigator.push,
          //   )  ],
        ),
      body: FadeInUp(
        duration: Duration(milliseconds: 700),
        child:  Padding(
          padding: EdgeInsets.all(7),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverToBoxAdapter(child: _buildCarousel(collections)),
              // SliverToBoxAdapter(child: _buildCategories(collections)),
              // SliverPadding(
              //   padding: const EdgeInsets.all(16),
              //   sliver: _buildCollectionsGrid(collections),
              // ),
              SliverToBoxAdapter(child: _buildFooter()),


            ],
          )

      ),
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
}
Widget _buildFooter() {
  return Container(
    padding: const EdgeInsets.all(20),
    color: Colors.grey[50],
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
            SizedBox(width: 5,),

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
            SizedBox(width: 5,),
            InkWell(
              child: Text('care.minknbear@gmail.com', style: TextStyle(color: Colors.grey[600])),
              onTap: () {
                launchUrl(Uri.parse('mailto:care.minknbear@gmail.com'));
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Social Media',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 24),
        const Text(
          'We are Open',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height:16),
        Text(
          'Our store has re-opened for shopping, exchanges Every day 10am to 6pm. ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height:26),

      Center(
        child: Text(
            '©Mink & Bear 2024',
            style: TextStyle(color: Colors.grey[400]),
          ),
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


