// core/constants/app_gradients.dart
import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      CorporativeColors.gradientColorTop, // Color inicial (#06060C)
      CorporativeColors.gradientColorBottom, // Color final (#1A1A36)
    ],
  );
}