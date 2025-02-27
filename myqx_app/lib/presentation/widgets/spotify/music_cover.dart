import 'package:flutter/material.dart';

class MusicCover extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;
  final BoxFit fitMode;
  
  const MusicCover({
    Key? key,
    required this.imageUrl,
    this.size = 100,
    this.borderRadius = 8.0,
    this.fitMode = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: 1.0, // Mantiene el aspect ratio cuadrado (1:1)
          child: Image.network(
            imageUrl,
            fit: fitMode,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}