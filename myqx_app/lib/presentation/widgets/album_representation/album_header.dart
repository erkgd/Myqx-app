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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final coverSize = isSmallScreen ? 120.0 : 140.0;

    return MusicContainer(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del álbum
            MusicCover(
              imageUrl: imageUrl,
              size: coverSize,
            ),
            
            const SizedBox(width: 15),
            
            // Área de información y controles
            Expanded(
              child: SizedBox(
                height: coverSize,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Artista
                    Text(
                      artist,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                   
                    // 2. Título del álbum
                    Text(
                      albumTitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 13,
                        color: Colors.white,
                        
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2), // Espacio reducido
                    
                    // 3. Año (más pequeño y discreto)
                    Text(
                      '$releaseYear',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CorporativeColors.mainColor,
                      ),
                    ),
                    
                    SizedBox(height: 5), // Empuja el botón hacia abajo

                    // 4. Botón de Spotify (más compacto y alineado a la izquierda)
                    OpenSpotifyButton(
                      spotifyUrl: spotifyUrl,
                      height: isSmallScreen ? 22 : 24,
                      text: isSmallScreen ? 'Open' : 'Open in Spotify',
                      // No definimos width para que use su tamaño intrínseco
                    ),
                    
                    // 5. Rating (alineado a la derecha)
                    Padding(
                      padding: const EdgeInsets.only(top: 25, left: 80),
                      child:Rating(
                        rating: rating, 
                        itemSize: isSmallScreen ? 16 : 22,
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