import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/review.dart';
import 'package:myqx_app/presentation/widgets/spotify/add_to_playlist.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_link.dart';
import 'package:myqx_app/presentation/widgets/spotify/user_circle.dart';
import 'package:myqx_app/presentation/widgets/spotify/music_cover.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/presentation/widgets/spotify/music_metadata.dart';

class RatedMusic extends StatelessWidget {
  final String imageUrl;
  final String artist;
  final String musicname;
  final String review;
  final double rating;
  final String user;

  const RatedMusic({
    super.key,
    required this.imageUrl,
    required this.artist,
    required this.musicname,
    required this.review,
    required this.rating,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return MusicContainer(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera sección: Portada, usuario y review
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portada del álbum (esquina superior izquierda) 
                MusicCover(imageUrl: imageUrl, size: 145),
                
                const SizedBox(width: 12),
                
                // Columna derecha (usuario y review)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Usuario - AHORA EN UNA FILA QUE LO EMPUJA A LA DERECHA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          UserCircle(
                            username: 'erkgd', 
                            imageUrl: imageUrl, 
                            imageSize: 24, 
                            fontSize: 14
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Review (debajo del usuario)
                      Review(reviewText: review),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Segunda sección: Metadata, iconos Spotify y rating
            Row(
              children: [
                // Metadata (artista y nombre)
                Expanded(
                  flex: 3,
                  child: MusicMetadata(
                    artist: artist, 
                    musicname: musicname
                  ),
                ),
                
                // ICONOS DE SPOTIFY MÁS CERCA DE LOS METADATOS
                const SizedBox(width: 2), // Reducido de 4 a 2
                SpotifyLink(
                  songUrl: Uri.parse('https://open.spotify.com/intl-es/track/0zn0GmUvU9wkqcj8slROu9?si=9166f09e829b4ccd'), 
                  size: 20
                ),
                const SizedBox(width: 2), // Reducido de 4 a 2
                AddToPlaylist(songId: 'songId', size: 20),
                
                const SizedBox(width: 8), // Este espacio se mantiene igual
                
                // Rating - SE MANTIENE DONDE ESTABA
                Rating(rating: rating, itemSize: 16),
              ],
            ),
          ],
        ),
      )
    );
  }
}