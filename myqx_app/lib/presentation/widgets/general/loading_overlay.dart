import 'package:flutter/material.dart';

/// Widget que muestra un indicador de carga sobre su hijo cuando isLoading es true
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? color;
  final double opacity;
  final Widget? loadingIndicator;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.color,
    this.opacity = 0.5,
    this.loadingIndicator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: (color ?? Colors.black).withOpacity(opacity),
                child: Center(
                  child: loadingIndicator ?? 
                         const CircularProgressIndicator(
                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                         ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}