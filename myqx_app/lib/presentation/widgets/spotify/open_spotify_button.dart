import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/spotify/spotify_link.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSpotifyButton extends StatelessWidget {
  final String spotifyUrl;
  final double height;
  final double? width;
  final String text;
  
  const OpenSpotifyButton({
    Key? key,
    required this.spotifyUrl,
    this.height = 40,
    this.width,
    this.text = 'Abrir Spotify',
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
  }

  Future<void> _launchSpotify() async {
    try {
      final Uri uri = Uri.parse(spotifyUrl);
      
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        debugPrint('No se pudo abrir $spotifyUrl');
      }
    } catch (e) {
      debugPrint('Error al abrir Spotify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchSpotify,
      child: Container(
        height: height,
        width: width,
        constraints: const BoxConstraints(minWidth: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
          color: Colors.transparent,
        ),
        // Añadido padding horizontal dentro del botón
        padding: const EdgeInsets.symmetric(horizontal: 10.0),        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Extraer ID y tipo de contenido de la URL de Spotify
            SpotifyLink(
              contentId: _extractSpotifyId(spotifyUrl),
              contentType: _extractContentType(spotifyUrl),
              size: 16
            ),
            
            if (text.isNotEmpty) ...[
              const SizedBox(width: 6), // Espaciado entre icono y texto
              
              // Texto con tamaño reducido
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Reducido de 14 a 12
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}