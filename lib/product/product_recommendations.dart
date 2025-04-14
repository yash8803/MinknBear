import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'product_card.dart';

class ProductRecommandations extends StatefulWidget {
  final String productId;

  const ProductRecommandations({super.key, required this.productId});

  @override
  State<ProductRecommandations> createState() => _ProductRecommandationsState();
}

class _ProductRecommandationsState extends State<ProductRecommandations> {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(r'''
          query productRecommendations($productId: ID!) {
            productRecommendations (productId: $productId) {
              id
              title
              handle
              descriptionHtml
              featuredImage {
                id
                url (transform: { maxWidth: 480, maxHeight: 480 })
                altText
              }
              images (first: 5) {
                edges {
                  node {
                    transformedSrc(maxWidth: 480, maxHeight: 480)
                    altText
                  }
                }
              }
              options (first: 50) {
                id
                name
                values
              }
              variants (first: 50) {
                  edges {
                    node {
                      id
                      title
                      availableForSale
                       image {
                                id
                              }
                      price{
                        amount
                        currencyCode
                      }
                      compareAtPrice {
                        amount
                        currencyCode
                      }
                      selectedOptions {
                        name
                        value
                      }
                    }
                  }
                }
              compareAtPriceRange {
                minVariantPrice { amount currencyCode }
                maxVariantPrice { amount currencyCode }
              }
              priceRange {
                minVariantPrice { amount currencyCode }
                maxVariantPrice { amount currencyCode }
              }
              metafields(identifiers: [
                { namespace: "reviews" key: "rating" }
                { namespace: "reviews" key: "rating_count" }
              ]) {
                type
                namespace
                key
                value
              }
            }
          }
        '''),
        variables: {
          'productId': widget.productId,
        },
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading, please wait',
              color: Colors.black,
            ),
          );
        }

        // Error handling
        if (result.hasException) {
          return Center(
            child: Text(
              'Error: ${result.exception.toString()}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final List products = result.data!['productRecommendations'];

        // Empty state
        if (products.isEmpty) {
          return const Center(
            child: Text('No recommendations available at the moment.'),
          );
        }

        // Responsive GridView for product cards
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          child: Column(
            children: [
              const Text(
                'Recommended Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 13,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
