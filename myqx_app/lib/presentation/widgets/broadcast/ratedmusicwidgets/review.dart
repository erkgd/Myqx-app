import 'package:flutter/material.dart';

class Review extends StatelessWidget {
  final String reviewText;
  final double fontSize;
  final Color textColor;

  const Review({
    Key? key,
    required this.reviewText,
    this.fontSize = 10.0,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override  Widget build(BuildContext context) {
    // Debug para asegurar que el texto de la review llega a este widget
    debugPrint('[REVIEW_WIDGET] Renderizando review: "$reviewText"');
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Text(
            reviewText,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.justify,
            softWrap: true,
            overflow: TextOverflow.fade, // Usa fade en lugar de ellipsis
            maxLines: null, // Permite múltiples líneas según sea necesario
          ),
        );
      },
    );
  }
}