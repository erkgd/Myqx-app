import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class Rating extends StatelessWidget {
  final double rating;
  final double itemSize;
  final Function(double)? onRatingUpdate;
  final bool rateable; // Nueva variable para controlar si se puede modificar

  const Rating({
    Key? key,
    this.rating = 0.0, // Valor por defecto en cero
    this.itemSize = 12.0,
    this.onRatingUpdate,
    this.rateable = true, // Por defecto se puede modificar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no es rateable o onRatingUpdate es null, mostrar el indicador de solo lectura
    if (!rateable || onRatingUpdate == null) {
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
    
    // Si es rateable Y onRatingUpdate NO es null, mostrar el rating interactivo
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: itemSize,
      unratedColor: CorporativeColors.darkColor,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: CorporativeColors.whiteColor,
      ),
      onRatingUpdate: onRatingUpdate!,
      glow: false, // Desactivar el efecto "glow" para un aspecto más limpio
    );
  }
}