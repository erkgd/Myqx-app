// filepath: c:\Users\aleja\Desktop\BINFO\TFB\Myqx\Myqx-app\myqx_app\lib\presentation\widgets\broadcast\rated_music_element.dart
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
  final String? review;
  final int rating;
  final String user;

  const RatedMusic({
    super.key,
    required this.imageUrl,
    required this.artist,
    required this.musicname,
    this.review,
    required this.rating,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return MusicContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Aumentado de 12.0 a 16.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera sección: Portada, usuario y review
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portada del álbum (esquina superior izquierda) 
                MusicCover(imageUrl: imageUrl, size: 145),
                
                const SizedBox(width: 16), // Aumentado de 12 a 16
                
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
                            username: user, 
                            imageUrl: imageUrl, 
                            imageSize: 24, 
                            fontSize: 14
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                        // Review con padding añadido - Mostrar solo si hay una review
                      Builder(builder: (context) {
                        // Debug para verificar si la review llega al widget
                        debugPrint('[RATED_MUSIC] Review recibida para widget: ${review != null ? "\"$review\"" : "NULL"}');
                        
                        if (review != null && review!.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título de la review
                                const Text(
                                  "Comentario:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Review
                                Review(reviewText: review!, fontSize: 11),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox.shrink(); // Widget vacío si no hay review
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16), // Aumentado de 12 a 16
            
            // Segunda sección: Metadata, iconos Spotify y rating
            Row(
              children: [
                // Metadata (artista y nombre) con los iconos de Spotify integrados
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: MusicMetadata(
                          artist: artist, 
                          musicname: musicname
                        ),
                      ),
                      // ICONOS DE SPOTIFY PEGADOS A LOS METADATOS (sin SizedBox)
                      SpotifyLink(
                        songUrl: Uri.parse('https://open.spotify.com/intl-es/track/0zn0GmUvU9wkqcj8slROu9?si=9166f09e829b4ccd'), 
                        size: 25
                      ),
                      const SizedBox(width: 2),
                      AddToPlaylist(songId: 'songId', size: 25),
                    ],
                  ),
                ),
                
                const SizedBox(width: 40), // Este espacio se mantiene igual
                
                // Rating - Convertir de int a double para el widget
                Rating(rating: rating.toDouble(), itemSize: 14),
              ],
            ),
          ],
        ),
      )
    );
  }
}