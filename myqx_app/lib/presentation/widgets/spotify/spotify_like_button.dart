import 'package:flutter/material.dart';
import 'package:myqx_app/core/services/spotify_like_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget para mostrar y manejar el botón de "me gusta" de Spotify
class SpotifyLikeButton extends StatefulWidget {
  final String contentId;
  final String contentType;
  final double size;
  final Function(bool)? onLikeChanged;
  final SpotifyLikeService likeService;
  
  /// Constructor del botón de "me gusta" de Spotify
  /// 
  /// [contentId] - ID del contenido en Spotify
  /// [contentType] - Tipo de contenido ('album' o 'track')
  /// [size] - Tamaño del ícono (opcional)
  /// [onLikeChanged] - Función a ejecutar cuando cambia el estado de "me gusta" (opcional)
  /// [likeService] - Servicio para gestionar los "me gusta" (opcional)
  SpotifyLikeButton({
    super.key,
    required this.contentId,
    required this.contentType,
    this.size = 24.0,
    this.onLikeChanged,
    SpotifyLikeService? likeService,
  }) : likeService = likeService ?? SpotifyLikeService();
  
  @override
  State<SpotifyLikeButton> createState() => _SpotifyLikeButtonState();
}

class _SpotifyLikeButtonState extends State<SpotifyLikeButton> {
  bool _isLiked = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
  }
  
  @override
  void didUpdateWidget(SpotifyLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el contenido, verificar el nuevo estado
    if (oldWidget.contentId != widget.contentId || 
        oldWidget.contentType != widget.contentType) {
      _checkLikeStatus();
    }
  }
  
  /// Verifica el estado actual de "me gusta" del contenido
  Future<void> _checkLikeStatus() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final isLiked = await widget.likeService.isContentLiked(
        widget.contentId, 
        widget.contentType,
      );
      
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE_BUTTON] Error verificando estado: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
    /// Maneja el clic en el botón para cambiar el estado de "me gusta"
  Future<void> _handleLikeToggle() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      
      // Usar el nuevo método toggleLike para alternar el estado
      final success = await widget.likeService.toggleLike(
        widget.contentId,
        widget.contentType,
        _isLiked,  // Pasar el estado actual
      );
      
      if (success && mounted) {
        setState(() {
          _isLiked = !_isLiked; // Invertir el estado actual
          _isLoading = false;
        });
        
        // Notificar el cambio si existe un callback
        if (widget.onLikeChanged != null) {
          widget.onLikeChanged!(_isLiked);
        }
        
        // Mostrar mensaje de éxito según la acción realizada (añadir o quitar)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLiked 
                  ? '¡Añadido a tus ${widget.contentType == 'album' ? 'álbumes' : 'canciones'} favoritos!' 
                  : '¡Quitado de tus ${widget.contentType == 'album' ? 'álbumes' : 'canciones'} favoritos!'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar mensaje de error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo añadir a favoritos. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Mostrar mensaje de error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Usar un contenedor con tamaño fijo para evitar deslizamiento del layout
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: _isLoading 
          // Estado de carga - un spinner centrado
          ? SizedBox(
              width: widget.size * 1,
              height: widget.size * 1,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          // Estado normal - botón de like
          : IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(
                width: widget.size,
                height: widget.size,
              ),              icon: _isLiked 
                ? SvgPicture.asset(
                    'assets/images/spotify-icon-liked.svg',
                    width: widget.size * 1,
                    height: widget.size * 1,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1DB954),
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => Icon(
                      Icons.favorite,
                      color: const Color(0xFF1DB954),
                      size: widget.size * 1,
                    ),
                  )
                : SvgPicture.asset(
                    'assets/images/spotify-like-icon.svg',
                    width: widget.size * 1,
                    height: widget.size * 1,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFFFFFF),
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => Icon(
                      Icons.favorite_border,
                      color: const Color(0xFFFFFFFF),
                      size: widget.size * 1,
                    ),
                  ),
              onPressed: _handleLikeToggle,
              iconSize: widget.size,
              splashRadius: widget.size * 1,
              tooltip: _isLiked 
                ? 'Ya está en tus favoritos' 
                : 'Añadir a tus favoritos de Spotify',
            ),
    );
  }
}
