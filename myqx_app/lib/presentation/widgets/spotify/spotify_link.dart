import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpotifyLink extends StatelessWidget {
  final String contentId;
  final String contentType;
  final double size;

  const SpotifyLink({
    Key? key, 
    required this.contentId, 
    required this.contentType, 
    required this.size
  }) : super(key: key);

  /// Extrae el ID normalizado para Spotify y maneja distintos formatos
  String _getNormalizedId() {
    String normalizedId = contentId;
    
    // Si el ID tiene el formato "spotify:album:1234" o "spotify:track:1234", extraer solo el ID
    if (contentId.contains('spotify:album:')) {
      normalizedId = contentId.split('spotify:album:').last;
    } else if (contentId.contains('spotify:track:')) {
      normalizedId = contentId.split('spotify:track:').last;
    }
    
    return normalizedId;
  }

  Future<void> _launchURL() async {
    final String normalizedId = _getNormalizedId();
    
    // Construir URL apropiada según el tipo de contenido
    final Uri url = Uri.parse(
      contentType.toLowerCase() == 'album'
          ? 'https://open.spotify.com/album/$normalizedId'
          : 'https://open.spotify.com/track/$normalizedId'
    );
    
    debugPrint('[SPOTIFY_LINK] Abriendo URL: $url para contentId=$contentId, contentType=$contentType');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('[SPOTIFY_LINK] No se pudo lanzar la URL: $url');
      }
    } catch (e) {
      debugPrint('[SPOTIFY_LINK] Error al abrir URL $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar un contenedor con tamaño fijo para evitar deslizamiento del layout
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _launchURL,
        child: SvgPicture.asset(
          'assets/images/spotifyLogo.svg',
          width: size * 0.9, // Ligera reducción para evitar desbordamiento
          height: size * 0.9,
          colorFilter: ColorFilter.mode(CorporativeColors.spotifyColor, BlendMode.srcIn),
          placeholderBuilder: (context) => Icon(
            Icons.music_note,
            color: CorporativeColors.spotifyColor,
            size: size * 0.8,
          ),
        ),
      ),
    );
  }
}