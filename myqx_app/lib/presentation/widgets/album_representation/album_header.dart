import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/presentation/widgets/spotify/music_cover.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';

class AlbumHeader extends StatelessWidget {
  final String albumTitle;
  final String artist;
  final String imageUrl;
  final String releaseYear;
  final double rating;
  final String spotifyUrl;

  const AlbumHeader({
    Key? key,
    required this.albumTitle,
    required this.artist,
    required this.imageUrl,
    required this.releaseYear,
    required this.rating,
    required this.spotifyUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar el tamaño disponible
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Ajustar el tamaño de la portada según el tamaño de pantalla
    final coverSize = isSmallScreen ? 120.0 : 140.0;

    return MusicContainer(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del álbum (lado izquierdo)
            MusicCover(
              imageUrl: imageUrl,
              size: coverSize,
            ),
            
            const SizedBox(width: 12),
            
            // Contenido textual y botón (lado derecho)
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: coverSize, // Asegura que la altura sea al menos la de la portada
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sección superior con información del álbum
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título del álbum
                        Text(
                          albumTitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Artista
                        Text(
                          artist,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 15,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Año de lanzamiento
                        Text(
                          '$releaseYear',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CorporativeColors.mainColor,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Rating
                        Rating(rating: rating, itemSize: isSmallScreen ? 14 : 16),
                      ],
                    ),
                    
                    // Botón de Spotify - ahora sin cálculos arriesgados
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OpenSpotifyButton(
                        spotifyUrl: spotifyUrl,
                        // Sin width específico, dejamos que se ajuste al padre
                        height: 34,
                        text: isSmallScreen ? 'Open' : 'Open in Spotify',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}