import 'package:flutter/material.dart';
import 'package:myqx_app/core/services/performance_service.dart';
import 'package:myqx_app/presentation/widgets/general/shimmer_effect.dart';

/// A widget that loads images lazily and efficiently
/// Uses PerformanceService for caching and optimization
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  
  const LazyImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  final PerformanceService _performanceService = PerformanceService();
  bool _isLoading = true;
  bool _hasError = false;
  ImageProvider? _imageProvider;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  
  @override
  void didUpdateWidget(LazyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }
  
  void _loadImage() {
    if (widget.imageUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Optimize image URL for the requested size
      final optimizedUrl = _performanceService.optimizeImageUrl(
        widget.imageUrl,
        width: widget.width?.toInt(),
        height: widget.height?.toInt(),
      );
      
      // Get image from cache or network
      _imageProvider = _performanceService.getProfileImage(optimizedUrl);
      
      final image = Image(
        image: _imageProvider!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
      
      // Preload image to check for errors
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
          (info, _) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onError: (exception, stackTrace) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }
    
    if (_hasError || _imageProvider == null) {
      return _buildErrorWidget();
    }
    
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Image(
        image: _imageProvider!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    if (widget.placeholder != null) return widget.placeholder!;
    
    return ShimmerEffect(
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          color: Colors.grey[300],
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) return widget.errorWidget!;
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        color: Colors.grey[200],
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
      ),
    );
  }
}
