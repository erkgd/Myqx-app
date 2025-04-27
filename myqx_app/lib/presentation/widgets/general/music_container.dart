import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class MusicContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double elevation;
  final BorderRadius? borderRadius;
  
  const MusicContainer({
    Key? key, 
    required this.child, 
    this.borderColor = CorporativeColors.whiteColor,
    this.elevation = 0.0,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0), // Aumentado de 16,5 a 20,6
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
        boxShadow: elevation > 0 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: elevation,
            spreadRadius: elevation * 0.3,
            offset: Offset(0, elevation * 0.5),
          )
        ] : null,
      ),
      child: child,
    );
  }
}