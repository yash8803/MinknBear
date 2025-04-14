import 'dart:convert';
import 'package:flutter/material.dart';

class ProductRatingStars extends StatelessWidget {
	final List metafields;
	final bool compact;

	// Cache the sizes to avoid recalculation
	final double _starSize;
	final double _fontSize;

	// Cache the rating data
	final double _rating;
	final int _ratingCount;
	final String _reviewText;

	ProductRatingStars({
		super.key,
		required this.metafields,
		required this.compact,
	}) : _starSize = compact ? 14 : 18,
				_fontSize = compact ? 11 : 13,
				_rating = _extractRating(metafields),
				_ratingCount = _extractRatingCount(metafields),
				_reviewText = _buildReviewText(_extractRatingCount(metafields));

	// Static helper methods for data extraction
	static double _extractRating(List metafields) {
		for (var elem in metafields) {
			if (elem?['key'] == 'rating') {
				try {
					final Map ratingAsMap = jsonDecode(elem['value']);
					return double.parse(ratingAsMap['value']);
				} catch (e) {
					return 0.0;
				}
			}
		}
		return 0.0;
	}

	static int _extractRatingCount(List metafields) {
		for (var elem in metafields) {
			if (elem?['key'] == 'rating_count') {
				try {
					return int.parse(elem['value']);
				} catch (e) {
					return 0;
				}
			}
		}
		return 0;
	}

	static String _buildReviewText(int count) {
		if (count == 0) return 'No reviews';
		return '$count ${count == 1 ? 'review' : 'reviews'}';
	}

	// Memoized star icon getter
	static IconData _getStarIcon(int index, double rating) {
		if (index + 1 <= rating.ceil()) {
			return Icons.star;
		}
		return (index + 1 - rating > 0) ? Icons.star_border : Icons.star_half;
	}

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				_buildStarRow(),
				const SizedBox(width: 2),
				Text(
					_reviewText,
					style: TextStyle(
						color: Colors.grey,
						fontSize: _fontSize,
					),
				),
			],
		);
	}

	Widget _buildStarRow() {
		return Row(
			mainAxisSize: MainAxisSize.min,
			children: List.generate(
				5,
						(index) => Icon(
					_getStarIcon(index, _rating),
					color: Colors.yellow.shade700,
					size: _starSize,
				),
				growable: false,  // Set to false since we know the size
			),
		);
	}
}