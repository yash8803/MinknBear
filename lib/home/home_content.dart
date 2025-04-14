import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shopify_flutter/home/skeleton_loader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../collection/collection.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _currentCarouselIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(r"""
          query collections() {
            collections (first: 50) {
              edges {
                node {
                  id,
                  title,
                  handle,
                  description,
                  image {
                    transformedSrc(maxWidth: 900, maxHeight: 720)
                    altText
                  }
                }
              }
            }
          }
        """),
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (result.hasException) {
          print(result.exception);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load collections',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (refetch != null) {
                      try {
                        await refetch();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Retry failed: $e'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
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
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }
        final collections = result.data!['collections']['edges'];

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildCarousel(collections)),
            SliverToBoxAdapter(child: _buildCategories(collections)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _buildCollectionsGrid(collections),
            ),
            SliverToBoxAdapter(child: _buildFooter()),

          ],
        );
      },
    );
  }



  Widget _buildCarousel(List<dynamic> collections) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: collections.length,
          options: CarouselOptions(
            height: 350,
            aspectRatio: 16/9,
            viewportFraction: 1.0,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildCarouselItem(collections[index]['node']);
          },
        ),
        const SizedBox(height: 12),
        _buildCarouselIndicators(collections.length),
      ],
    );
  }

  Widget _buildCarouselItem(dynamic collection) {
    final imageUrl = collection['image']?['transformedSrc'] ?? '';
    final title = collection['title'] ?? '';

    return GestureDetector(
      onTap: () => _navigateToCollection(context, collection),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SkeletonLoader(),
              errorWidget: (context, url, error) => const Icon(Icons.error_outline),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        length,
            (index) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentCarouselIndex == index
                ? Colors.black
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(List<dynamic> collections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: collections.length,
            itemBuilder: (context, index) => _buildCategoryItem(collections[index]['node']),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(dynamic node) {
    return GestureDetector(
      onTap: () => _navigateToCollection(context, node),
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: node['image']?['transformedSrc'] ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SkeletonLoader(),
                  errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              node['title'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCollectionsGrid(List<dynamic> collections) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCollectionCard(collections[index]),
        childCount: collections.length,
      ),
    );
  }
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
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

  Widget _buildCollectionCard(dynamic edge) {
    var node = edge['node'];
    var imageUrl = node['image']?['transformedSrc'] ?? '';
    var title = node['title'] ?? '';

    return GestureDetector(
      onTap: () => _navigateToCollection(context, node),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'collection-${node['id']}',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const SkeletonLoader(),
                  errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore Collection →',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCollection(BuildContext context, dynamic node) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollectionPage(
          id: node['id'],
          title: node['title'],
        ),
      ),
    );
  }
}