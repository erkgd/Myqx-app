import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_link.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';

class StarOfTheDay extends StatelessWidget {
  final String albumCoverUrl;
  final String artistName;
  final String songName;
  final String spotifyUrl;

  const StarOfTheDay({
    Key? key,
    required this.albumCoverUrl,
    required this.artistName,
    required this.songName,
    required this.spotifyUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetWidth = screenWidth * 0.55;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: targetWidth,
      ),
      child: MusicContainer(
        borderColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  children: [
                    // Columna con artista y nombre de canción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nombre del artista
                          Text(
                            artistName,
                            style: const TextStyle(
                              fontSize: 14,
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
                              fontSize: 12,
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
                    SpotifyLink(
                      songUrl: Uri.parse(spotifyUrl),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}