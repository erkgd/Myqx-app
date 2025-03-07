import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class LoadableContent<T> extends StatelessWidget {
  final T? data;
  final bool isLoading;
  final Widget Function(T data) builder;
  final Widget? placeholder;
  final double? height;
  final double? width;

  const LoadableContent({
    super.key,
    required this.isLoading,
    required this.data,
    required this.builder,
    this.placeholder,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: height,
        width: width,
        child: placeholder ?? const Center(
          child: CircularProgressIndicator(
            color: CorporativeColors.mainColor,
          ),
        ),
      );
    }
    
    if (data == null) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: Text(
            "No data available",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    
    return builder(data as T);
  }
}