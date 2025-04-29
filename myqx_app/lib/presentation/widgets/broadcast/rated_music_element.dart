// filepath: c:\Users\aleja\Desktop\BINFO\TFB\Myqx\Myqx-app\myqx_app\lib\presentation\widgets\broadcast\rated_music_element.dart
import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';
import 'package:myqx_app/presentation/widgets/spotify/add_to_playlist.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_like_button.dart'; // Nuevo import para el botón de me gusta
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
  final String userImageUrl; // URL de la foto de perfil del usuario
  final String contentType; // Tipo de contenido ('album' o 'track')
  final String contentId;   // ID del contenido en Spotify

  const RatedMusic({
    super.key,
    required this.imageUrl,
    required this.artist,
    required this.musicname,
    this.review,
    required this.rating,
    required this.user,
    required this.userImageUrl,
    required this.contentType,
    this.contentId = '',  // Parámetro opcional con valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    // Debug para verificar si la review llega al widget
    if (review != null && review!.isNotEmpty) {
      debugPrint('[RATED_MUSIC] Review recibida para widget: "$review" para $musicname');
    } else {
      debugPrint('[RATED_MUSIC] Sin review para $musicname');
    }
    
    // Debug para verificar qué tipo de contenido se está procesando y sus datos
    debugPrint('[RATED_MUSIC] Procesando $contentType - Título: "$musicname", Artista: "$artist", ImageURL: "$imageUrl"');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del tipo de contenido alineada a la DERECHA
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 20, bottom: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(13.0),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: Text(
              contentType == 'album' ? 'ÁLBUM' : 'CANCIÓN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // La tarjeta principal
        MusicContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera sección: Portada, usuario y review
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portada del álbum (esquina superior izquierda)
                    MusicCover(imageUrl: imageUrl, size: 145),
                    
                    const SizedBox(width: 16), // Espaciado entre portada y columna derecha
                    
                    // Columna derecha (usuario y review)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Usuario - En una fila que lo empuja a la derecha
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              UserCircle(
                                username: user, 
                                imageUrl: userImageUrl, // Usar la URL de imagen de perfil del usuario
                                imageSize: 24, 
                                fontSize: 14
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                            
                          // Review con mejor diseño - Mostrar solo si hay una review
                          if (review != null && review!.isNotEmpty && review!.toLowerCase() != "null")
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              padding: const EdgeInsets.all(12.0),
                              
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Review text
                                  Text(
                                    review!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      letterSpacing: 0.2, // Espaciado entre letras
                                      wordSpacing: 1.0,   // Espaciado consistente entre palabras
                                      height: 1.4,        // Altura de línea para mejor legibilidad
                                    ),
                                    textAlign: TextAlign.justify,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 8,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16), // Espaciado entre secciones
                
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
                          ),                          // ICONOS DE SPOTIFY PEGADOS A LOS METADATOS
                          SpotifyLink(
                            contentId: contentId,
                            contentType: contentType,
                            size: 25
                          ),
                          const SizedBox(width: 8),
                          // Botón para añadir a "Me gusta" de Spotify
                          SpotifyLikeButton(
                            contentId: contentId,
                            contentType: contentType,
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 40), // Espaciado entre metadata y rating
                    
                    // Rating - Convertir de int a double para el widget
                    Rating(rating: rating.toDouble(), itemSize: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}