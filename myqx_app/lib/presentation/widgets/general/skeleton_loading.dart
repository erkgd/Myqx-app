import 'package:flutter/material.dart';

/// Widget para mostrar un placeholder de carga animado (skeleton)
class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;
  
  const SkeletonLoading({
    Key? key,
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
    this.margin,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar animación
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle 
                ? BorderRadius.circular(8) 
                : null,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!.withOpacity(_animation.value),
                Colors.grey[100]!.withOpacity(_animation.value + 0.1),
                Colors.grey[300]!.withOpacity(_animation.value),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
