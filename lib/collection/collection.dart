import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../product/product_card.dart';

class CollectionPage extends StatefulWidget {
  final String id;
  final String title;

  const CollectionPage({super.key, required this.id, required this.title});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

const List<Map> _sortByList = [
  {'key': 'COLLECTION_DEFAULT', 'name': 'Default'},
  {'key': 'BEST_SELLING', 'name': 'Best Selling'},
  {'key': 'CREATED', 'name': 'Created'},
  {'key': 'PRICE', 'name': 'Price'},
  {'key': 'TITLE', 'name': 'Title'}
];

class _CollectionPageState extends State<CollectionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _listViewController = ScrollController();
  List? _products;
  bool _sortReverse = false;
  String _sortKey = _sortByList[0]['key'];
  bool _paginationLoading = false;
  Map? _paginationInfo;
  List _availableFilters = [];
  List _activeFilters = [];
  List<bool> _filtersExpansionsState = [];

  RangeValues? _filtersPriceRange;
  double _absolutePriceMin = 0.0; // Always 0
  double _absolutePriceMax = 0.0; // Max price from products
  double _priceStep = 100.0; // Adjust based on your price range

  Future<void> _getProducts({bool onInitState = false, int limit = 24, String? after}) async {
    final client = GraphQLProvider.of(context).value;

    List filters = _activeFilters.map((e) => e['input']).toList();

    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query collection(
            $id: ID
            $limit: Int
            $after: String
            $reverse: Boolean 
            $sortKey: ProductCollectionSortKeys
            $filters: [ProductFilter!]
          ) 
          {
            collection (id: $id) {
              id
              handle
              products (
                first: $limit
                after: $after
                reverse: $reverse
                sortKey: $sortKey
                filters: $filters
              ) 
              {
                edges { 
                  node {
                    id
                    title
                    handle
                    descriptionHtml
                    featuredImage {
                      id
                      url (transform: { maxWidth: 480, maxHeight: 480,} )
                      altText
                    }
                    images (first: 5) {
                      edges {
                        node {
                          transformedSrc(maxWidth: 480, maxHeight: 480,)
                          altText
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
                          price {
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
                  }
                }
                filters {
                  id label type
                  values { id label count input }
                }
                pageInfo {
                  endCursor
                  hasNextPage
                }
              }
            }
          }
        '''),
        variables: {
          'id': widget.id,
          'limit': limit,
          'after': after,
          'reverse': _sortReverse,
          'sortKey': _sortKey,
          'filters': filters,
        },
      ),
    );

    if (kDebugMode) {
      print(result);
    }

    if (result.hasException) {
      if (kDebugMode) {
        print('GraphQL Exception: ${result.exception.toString()}');
      }
      return;
    }

    setState(() {
      if (after == null) {
        _products = result.data!['collection']['products']['edges'];
      } else {
        _products = [..._products!, ...result.data!['collection']['products']['edges']];
      }

      _availableFilters = result.data!['collection']['products']['filters'];
      _paginationLoading = false;
      _paginationInfo = result.data!['collection']['products']['pageInfo'];

      if (_filtersExpansionsState.isEmpty) {
        _filtersExpansionsState = _availableFilters.map((e) => true).toList();
      }

      // Calculate the true maximum price from products
      double maxPrice = 0.0;
      for (var edge in _products!) {
        final product = edge['node'];
        final priceRange = product['priceRange'];
        final maxVariantPrice = double.parse(priceRange['maxVariantPrice']['amount'].toString());
        if (maxVariantPrice > maxPrice) {
          maxPrice = maxVariantPrice;
        }
      }

      _absolutePriceMin = 0.0; // Always set min to 0
      _absolutePriceMax = maxPrice > 0 ? maxPrice : 1000.0; // Fallback to 1000 if no products

      // Reset range on init or if null
      if (onInitState || _filtersPriceRange == null) {
        _filtersPriceRange = RangeValues(_absolutePriceMin, _absolutePriceMax);
      } else {
        _filtersPriceRange = RangeValues(
          _filtersPriceRange!.start.clamp(_absolutePriceMin, _absolutePriceMax),
          _filtersPriceRange!.end.clamp(_absolutePriceMin, _absolutePriceMax),
        );
      }

      if (kDebugMode) {
        print('Absolute Min: $_absolutePriceMin, Max: $_absolutePriceMax');
        print('Selected Range: ${_filtersPriceRange?.start} - ${_filtersPriceRange?.end}');
      }
    });
  }

  int? _getValidDivisions() {
    final range = _absolutePriceMax - _absolutePriceMin;
    if (range <= 0) return null;
    final calculatedDivisions = (range / _priceStep).floor();
    return calculatedDivisions > 0 ? calculatedDivisions : null;
  }

  bool _valueContainActiveFilter(Map value) {
    return _activeFilters.any((filter) => filter['id'] == value['id']);
  }

  @override
  void initState() {
    super.initState();
    _filtersPriceRange = null; // Reset on page entry
    _activeFilters.removeWhere(
            (filter) => filter['input'] is Map && filter['input'].containsKey('price'));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getProducts(onInitState: true);
    });
  }

  @override
  void dispose() {
    _listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        backgroundColor: seedColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 120,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.8),
                            Theme.of(context).primaryColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            'Filter Products',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: ExpansionPanelList(
                      expandedHeaderPadding: EdgeInsets.zero,
                      elevation: 0,
                      dividerColor: Colors.grey.shade700,
                      animationDuration: const Duration(milliseconds: 500),
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _filtersExpansionsState[index] = isExpanded;
                        });
                      },
                      children: [
                        for (MapEntry filter in _availableFilters.asMap().entries)
                          ExpansionPanel(
                            canTapOnHeader: true,
                            isExpanded: _filtersExpansionsState[filter.key],
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return ListTile(
                                title: Text(
                                  filter.value['label'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            },
                            body: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (filter.value['type'] == 'LIST')
                                    Transform.translate(
                                      offset: const Offset(0, -4),
                                      child: Wrap(
                                        spacing: 0,
                                        runSpacing: -6,
                                        children: [
                                          for (Map value in filter.value['values'])
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                unselectedWidgetColor: Colors.grey.shade400,
                                              ),
                                              child: Opacity(
                                                opacity: value['count'] == 0 ? .25 : 1,
                                                child: CheckboxListTile(
                                                  contentPadding: const EdgeInsets.fromLTRB(16, 0, 11, 0),
                                                  dense: true,
                                                  controlAffinity: ListTileControlAffinity.trailing,
                                                  title: RichText(
                                                    text: TextSpan(
                                                      text: value['label'],
                                                      style: const TextStyle(color: Colors.black),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text: '  (${value['count']})',
                                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  value: _valueContainActiveFilter(value),
                                                  onChanged: value['count'] == 0
                                                      ? null
                                                      : (_) {
                                                    setState(() {
                                                      if (_valueContainActiveFilter(value)) {
                                                        _activeFilters.removeWhere(
                                                                (element) => element['id'] == value['id']);
                                                      } else {
                                                        _activeFilters.add({
                                                          'id': value['id'],
                                                          'input': jsonDecode(value['input']),
                                                        });
                                                      }
                                                    });
                                                    _getProducts();
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  else if (filter.value['type'] == 'BOOLEAN')
                                    const Center() // TODO: Handle Boolean collection filter types
                                  else if (filter.value['type'] == 'PRICE_RANGE')
                                      Column(
                                        children: [
                                          RangeSlider(
                                            inactiveColor: Colors.grey[400],
                                            activeColor: Colors.black87,
                                            values: _filtersPriceRange ??
                                                RangeValues(_absolutePriceMin, _absolutePriceMax),
                                            min: _absolutePriceMin,
                                            max: _absolutePriceMax,
                                            divisions: _getValidDivisions(),
                                            labels: RangeLabels(
                                              "\₹${(_filtersPriceRange?.start ?? _absolutePriceMin).round()}",
                                              "\₹${(_filtersPriceRange?.end ?? _absolutePriceMax).round()}",
                                            ),
                                            onChanged: (RangeValues values) {
                                              final snappedStart =
                                                  (values.start / _priceStep).round() * _priceStep;
                                              final snappedEnd = (values.end / _priceStep).round() * _priceStep;

                                              setState(() {
                                                _filtersPriceRange = RangeValues(
                                                  snappedStart.clamp(_absolutePriceMin, _absolutePriceMax),
                                                  snappedEnd.clamp(_absolutePriceMin, _absolutePriceMax),
                                                );
                                              });
                                            },
                                            onChangeEnd: (RangeValues values) {
                                              Map value = filter.value['values'][0];

                                              setState(() {
                                                _activeFilters
                                                    .removeWhere((element) => element['id'] == value['id']);
                                                _activeFilters.add({
                                                  'id': value['id'],
                                                  'input': {
                                                    'price': {
                                                      'min': _filtersPriceRange!.start,
                                                      'max': _filtersPriceRange!.end
                                                    }
                                                  },
                                                });
                                              });

                                              _getProducts();
                                            },
                                          ),
                                          Transform.translate(
                                            offset: const Offset(0, -4),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                      "\₹${(_filtersPriceRange?.start ?? _absolutePriceMin).round()}",
                                                      style: TextStyle(color: Colors.black)),
                                                  Text('To', style: const TextStyle(color: Colors.black)),
                                                  Text(
                                                      "\₹${(_filtersPriceRange?.end ?? _absolutePriceMax).round()}",
                                                      style: TextStyle(color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Show Products', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  if (_activeFilters.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        setState(() {
                          _activeFilters = [];
                          _filtersPriceRange = RangeValues(_absolutePriceMin, _absolutePriceMax);
                        });
                        _getProducts();
                      },
                      child: Text(
                        'Clear all (${_activeFilters.length})',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _products == null
          ? const Center(
          child: CircularProgressIndicator(
              semanticsLabel: 'Loading, please wait', color: Colors.black))
          : _products!.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 28, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No products found!'),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 200));
                _scaffoldKey.currentState!.openEndDrawer();
              },
              child: const Text('Show Filters'),
            )
          ],
        ),
      )
          : NotificationListener<ScrollEndNotification>(
        onNotification: (scrollEnd) {
          if (scrollEnd.metrics.atEdge) {
            bool isTop = scrollEnd.metrics.pixels == 0;
            if (isTop) return false;

            if (_paginationInfo != null && _paginationInfo!['hasNextPage']) {
              setState(() {
                _paginationLoading = true;
              });
              _getProducts(after: _paginationInfo!['endCursor']);
            }
          }
          return false;
        },
        child: CustomScrollView(
          controller: _listViewController,
          slivers: [
            SliverAppBar(
              scrolledUnderElevation: 0,
              pinned: true,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: seedColor,
              elevation: 0,
              title: Text(widget.title),
              actions: [
                IconButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 200));
                    if (context.mounted) {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Sort by',
                                          style: TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center),
                                      StatefulBuilder(
                                        builder: (BuildContext context, setState) => Row(
                                          children: [
                                            const Text('Reverse sort',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 4),
                                            Switch(
                                              value: _sortReverse,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  _sortReverse = !_sortReverse;
                                                });
                                                _getProducts();
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                for (Map item in _sortByList)
                                  RadioListTile(
                                    value: item['key'],
                                    groupValue: _sortKey,
                                    onChanged: (value) async {
                                      setState(() {
                                        _sortKey = item['key'];
                                      });
                                      await Future.delayed(const Duration(milliseconds: 200));
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      if (_listViewController.hasClients) {
                                        _listViewController.animateTo(
                                          0,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                      _getProducts();
                                    },
                                    title: Text(item['name']),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.sort_by_alpha),
                ),
                IconButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 200));
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width / 2.1,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return ProductCard(product: _products![index]['node']);
                  },
                  childCount: _products!.length,
                ),
              ),
            ),
            if (_paginationLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: LinearProgressIndicator(semanticsLabel: 'Loading'),
                ),
              ),
            SliverToBoxAdapter(
              child: _buildFooter(),
            ),
          ],
        ),
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
          InkWell(
            child: Text('+91 7405899480', style: TextStyle(color: Colors.grey[600])),
            onTap: () {
              launchUrl(Uri.parse('tel:+91 7405899480'));
            },
          ),
          const SizedBox(height: 8),
          InkWell(
            child: Text('care.minknbear@gmail.com', style: TextStyle(color: Colors.grey[600])),
            onTap: () {
              launchUrl(Uri.parse('mailto:care.minknbear@gmail.com'));
            },
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
          if (assetPath == 'assets/social-icons/facebook.svg') {
            launchUrl(Uri.parse('https://www.facebook.com/minknbearClothing'));
          }
          if (assetPath == 'assets/social-icons/instagram.svg') {
            launchUrl(Uri.parse('https://www.instagram.com/minknbearclothing/'));
          }
          if (assetPath == 'assets/social-icons/youtube.svg') {
            launchUrl(Uri.parse('https://www.youtube.com/@MinknBear'));
          }
        },
      ),
    );
  }
}