import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/app_gradients.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: child,
    );
  }
}