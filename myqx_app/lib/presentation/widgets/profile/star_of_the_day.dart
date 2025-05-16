import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_link.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';

class StarOfTheDay extends StatelessWidget {  final String albumCoverUrl;
  final String artistName;
  final String songName;
  final String spotifyUrl;
  final String? title;

  const StarOfTheDay({
    Key? key,
    required this.albumCoverUrl,
    required this.artistName,
    required this.songName,
    required this.spotifyUrl,
    this.title,
  }) : super(key: key);
  
  /// Extrae el ID de Spotify de una URL completa
  String _extractSpotifyId(String url) {
    // Formato típico: https://open.spotify.com/album/1234567890 o https://open.spotify.com/track/1234567890
    final Uri uri = Uri.parse(url);
    final List<String> segments = uri.pathSegments;
    
    if (segments.length >= 2) {
      return segments.last; // El último segmento es el ID
    }
    
    // Fallback, devolver un fragmento de la URL como ID
    return url.split('/').last;
  }
  
  /// Determina el tipo de contenido (album o track) de una URL de Spotify
  String _extractContentType(String url) {
    if (url.contains('/album/')) {
      return 'album';
    } else if (url.contains('/track/')) {
      return 'track';
    } else {
      // Valor predeterminado si no se puede determinar el tipo
      return 'track';
    }
  }  @override
  Widget build(BuildContext context) {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenedor principal
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: 255,
          ),      
          child: MusicContainer(
            borderColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [              // Título interno - solo se muestra si se proporciona
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 12.0),
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Portada del álbum con padding
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: AspectRatio(
                  aspectRatio: 1.0, // Relación 1:1 (cuadrado)
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.network(
                      albumCoverUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                CorporativeColors.mainColor),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.music_note, size: 60, color: Colors.white54),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
                // Información de la canción y logo de Spotify en una fila
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Columna con artista y nombre de canción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [// Nombre del artista
                          Text(
                            artistName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          // Nombre de la canción
                          Text(
                            songName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                      // Pequeño espacio entre los metadatos y el icono
                    const SizedBox(width: 8),
                    // Logo de Spotify a la derecha de los metadatos                    
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: SpotifyLink(
                        contentId: _extractSpotifyId(spotifyUrl),
                        contentType: _extractContentType(spotifyUrl),
                        size: 20, // Tamaño ligeramente más pequeño
                      ),
                    ),                  ],
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}