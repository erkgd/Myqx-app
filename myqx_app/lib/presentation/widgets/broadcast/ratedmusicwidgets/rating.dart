import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class Rating extends StatelessWidget {
  final double rating;
  final double itemSize;

  const Rating({
    Key? key,
    required this.rating,
    this.itemSize = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: CorporativeColors.whiteColor,
      ),
      itemCount: 5,
      itemSize: itemSize,
      unratedColor: CorporativeColors.darkColor,
      direction: Axis.horizontal,
    );
  }
}