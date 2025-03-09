import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:myqx_app/presentation/screens/album_screen.dart';

class MusicCover extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;
  final BoxFit fitMode;
  final String? albumId; // Añadimos albumId para navegación
  final bool isNavigable; // Indica si la portada debe navegar a un álbum
  final Map<String, dynamic>? albumData; // Datos básicos del álbum si están disponibles
  
  const MusicCover({
    Key? key,
    required this.imageUrl,
    this.size = 100,
    this.borderRadius = 8.0,
    this.fitMode = BoxFit.cover,
    this.albumId,
    this.isNavigable = false,
    this.albumData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget coverWidget = SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: 1.0,
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
    
    // Si no es navegable o no hay albumId, retornar simplemente la imagen
    if (!isNavigable || (albumId == null && albumData == null)) {
      return coverWidget;
    }
    
    // Si es navegable, envolver en GestureDetector con efecto visual
    return Stack(
      children: [
        // Imagen base
        coverWidget,
        
        // Overlay para efecto visual y feedback táctil
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToAlbumScreen(context),
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: Colors.white24,
              highlightColor: Colors.black26,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Método para navegar al AlbumScreen
  void _navigateToAlbumScreen(BuildContext context) {
    // Si tenemos un ID de álbum, navegar directamente a AlbumScreen
    if (albumId != null) {
      Provider.of<NavigationProvider>(context, listen: false)
          .navigateToAlbumById(context, albumId!);
    } 
    // Si tenemos datos básicos del álbum, usarlos para la navegación
    else if (albumData != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AlbumScreen(
            albumTitle: albumData!['albumTitle'] ?? '',
            artist: albumData!['artist'] ?? '',
            imageUrl: imageUrl,
            releaseYear: albumData!['releaseYear'] ?? '',
            rating: albumData!['rating'] ?? 0.0,
            spotifyUrl: albumData!['spotifyUrl'] ?? '',
            trackList: const [], // Lista vacía, se cargará después
          ),
        ),
      );
    }
  }
}