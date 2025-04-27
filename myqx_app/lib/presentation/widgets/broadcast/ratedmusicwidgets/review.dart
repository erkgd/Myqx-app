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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Text(
            reviewText,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
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