import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductAccordion extends StatefulWidget {
  final Map product;

  const ProductAccordion({super.key, required this.product});

  @override
  State<ProductAccordion> createState() => _ProductAccordionState();
}

class _ProductAccordionState extends State<ProductAccordion> {
  int _expnadedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        elevation: 0,
        dividerColor: Colors.grey.shade200,
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _expnadedIndex = _expnadedIndex == index ? -1 : index;
          });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: _expnadedIndex == 0,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                title: Text('Details'),
                contentPadding: EdgeInsets.only(left: 6),
              );
            },
            body: Html(data: widget.product['descriptionHtml'],),
          ),
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: _expnadedIndex == 1,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(
                title: Text('Shipping & Returns'),
                contentPadding: EdgeInsets.only(left: 6),
              );
            },
            body: Html(data: """        
						<ul>
							<li>We ship to all locations within the All over India.</li>
							<li>Orders are typically processed and shipped within 4-6 business days.</li>
							<li>Returns are accepted within 72 hours (3 days) of your purchase to maintain our inventory freshness and ensure prompt availability for other customers.</li>
							<li>Mink & Bear will arrange your pickup within 2-3 business days of your request. To facilitate an efficient return process, please make sure all products are unused, unwashed, and returned in their original packaging with tags intact.</li>
						</ul>
					"""),
          ),
        ]
    );
  }
}