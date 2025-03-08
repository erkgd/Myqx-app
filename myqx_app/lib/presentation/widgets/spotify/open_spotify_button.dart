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
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de Spotify
            SpotifyLink(songUrl: Uri.parse(spotifyUrl), size: 16), // Reducido tamaño
            
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