import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/search_service.dart';
import 'package:myqx_app/core/services/audio_player_service.dart';
import 'package:myqx_app/core/utils/rating_cache.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';
import 'package:url_launcher/url_launcher.dart';

class AlbumTrackCard extends StatefulWidget {
  final int trackNumber;
  final String trackName;
  final String albumCoverUrl;
  final String spotifyUrl;
  final String songId;
  final double rating;
  final Function(double)? onRatingChanged;
  final VoidCallback? onPlayPressed;
  final bool loadRating;
  final String? artistName;
  final String? previewUrl; // URL para reproducir vista previa
  
  const AlbumTrackCard({
    Key? key,
    required this.trackNumber,
    required this.trackName,
    required this.albumCoverUrl,
    required this.spotifyUrl,
    required this.songId,
    this.rating = 0.0,
    this.onRatingChanged,
    this.onPlayPressed,
    this.loadRating = true,
    this.artistName,
    this.previewUrl, // URL de previsualización de audio
  }) : super(key: key);

  @override
  State<AlbumTrackCard> createState() => _AlbumTrackCardState();
}

class _AlbumTrackCardState extends State<AlbumTrackCard> {
  double _currentRating = 0;
  bool _expanded = false;
  Timer? _debounceTimer;
  late SearchService _ratingService;
  late AudioPlayerService _audioService;
  
  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _ratingService = SearchService();
    _audioService = AudioPlayerService();
    _loadCachedOrServerRating();
    
    // Nos suscribimos a los cambios en el estado del reproductor de audio
    _audioService.addListener(_audioStateChanged);
  }
  
  void _audioStateChanged() {
    // Forzar redibujado para actualizar el icono de reproducción
    if (mounted) setState(() {});
  }
  
  void _loadCachedOrServerRating() {
    // Verificar si hay calificación en caché antes de cargar
    final cachedRating = RatingCache().getTrackRating(widget.songId);
    if (cachedRating != null) {
      _currentRating = cachedRating;
      debugPrint('[CACHE] Using cached track rating for UI: ${widget.songId} - $cachedRating');
    }
    // Cargar calificación del servidor solo si está habilitado y no tenemos caché
    else if (widget.loadRating) {
      _loadCurrentRating();
    } else {
      debugPrint('[DEBUG] Song rating loading skipped for: ${widget.songId}');
    }
  }
  
  Future<void> _loadCurrentRating() async {
    if (widget.songId.isEmpty) return;
    
    try {
      final rating = await _ratingService.getSongRating(widget.songId);
      if (rating != null && mounted) {
        setState(() {
          _currentRating = rating;
        });
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to load track rating: $e');
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _audioService.removeListener(_audioStateChanged);
    super.dispose();
  }

  // Maneja la actualización de calificación cuando el usuario interactúa con las estrellas
  void _handleRatingUpdate(double newRating) {
    setState(() {
      _currentRating = newRating;
    });
    
    // Guardar inmediatamente en caché para persistencia durante scroll
    RatingCache().setTrackRating(widget.songId, newRating);
    debugPrint('[CACHE] Provisional rating cached: ${widget.songId} - $newRating');
    
    // Cancelar timer previo y programar animación para mostrar botón de confirmar
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(seconds: 1), 
      () {
        if (mounted) {
          setState(() {
            _expanded = true;
          });
        }
      }
    );
    
    // Notificar al padre si es necesario
    widget.onRatingChanged?.call(newRating);
  }

  // Maneja la confirmación de la calificación
  Future<void> _handleRatingConfirmation() async {
    // Guardar en caché inmediatamente
    RatingCache().setTrackRating(widget.songId, _currentRating);
    
    // Enviar la calificación al servidor
    final success = await _ratingService.rateSong(widget.songId, _currentRating);
    debugPrint('[RATING] Song rated: ${widget.songId} - $_currentRating (success: $success, cached locally)');
    
    // Mostrar mensaje de éxito
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating saved successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    // Ocultar panel de confirmación
    if (mounted) {
      setState(() {
        _expanded = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final animationDuration = const Duration(milliseconds: 300);
    final animationCurve = Curves.easeInOut;
    
    return MusicContainer(
      borderColor: Colors.white,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0), // Pequeño padding superior adicional
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Alineación a la derecha para todo el contenedor
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fila principal con información de la canción
            _buildTrackInfoRow(isSmallScreen),
            
            // Línea divisoria blanca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                color: Colors.white.withOpacity(0.3),
                height: 1,
                thickness: 0.5,
              ),
            ),
            
            // Fila del sistema de calificación
            _buildRatingRow(animationDuration, animationCurve, isSmallScreen),
          ],
        ),
      ),
    );
  }
  
  // Construye la fila con la información principal de la canción
  Widget _buildTrackInfoRow(bool isSmallScreen) {
    return SizedBox(
      height: 64, // Aumentado de 60 a 64 para dar más margen superior
      width: double.infinity, // Asegura que ocupe todo el ancho
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start, // Mantiene la información alineada a la izquierda
        children: [
          // Número de pista
          _buildTrackNumber(),
          
          // Carátula del álbum
          _buildAlbumCover(),
          
          const SizedBox(width: 12),
          
          // Información de la pista (título y artista)
          _buildTrackDetails(isSmallScreen),
          
          // Botón de reproducción
          _buildPlayButton(),
        ],
      ),
    );
  }
  
  // Construye el número de pista
  Widget _buildTrackNumber() {
    return Container(
      width: 32,
      alignment: Alignment.center,
      child: Text(
        '${widget.trackNumber}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CorporativeColors.mainColor,
        ),
      ),
    );
  }
  
  // Construye la carátula del álbum
  Widget _buildAlbumCover() {
    if (widget.albumCoverUrl.isEmpty) {
      return const SizedBox(width: 0);
    }
    
    return Container(
      width: 45,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(widget.albumCoverUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  
  // Construye los detalles de la pista (título y artista)
  Widget _buildTrackDetails(bool isSmallScreen) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nombre de la pista
          Text(
            widget.trackName,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Nombre del artista
          Text(
            _getArtistName(),
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              fontWeight: FontWeight.normal,
              color: Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Obtiene el nombre del artista de las diferentes fuentes posibles
  String _getArtistName() {
    if (widget.artistName != null && widget.artistName!.isNotEmpty) {
      return widget.artistName!;
    } else if (widget.trackName.contains(" - ")) {
      return widget.trackName.split(" - ").last;
    } else {
      return "Unknown Artist";
    }
  }
  
  // Construye el botón de reproducción
  Widget _buildPlayButton() {
    final bool isCurrentlyPlaying = _audioService.currentlyPlayingId == widget.songId && _audioService.isPlaying;
    
    return Container(
      margin: const EdgeInsets.only(right: 12, left: 4),
      decoration: BoxDecoration(
        color: CorporativeColors.mainColor.withOpacity(isCurrentlyPlaying ? 0.3 : 0.15),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              isCurrentlyPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: CorporativeColors.mainColor,
              size: 28,
            ),
            onPressed: widget.onPlayPressed ?? () async {
              if (widget.previewUrl != null && widget.previewUrl!.isNotEmpty) {
                // Reproducir la previsualización si está disponible
                _audioService.playPreview(widget.previewUrl, widget.songId);
                debugPrint('Reproduciendo previsualización: ${widget.trackName}');
              } else if (widget.spotifyUrl.isNotEmpty) {
                // Si no hay vista previa, abrir la URL de Spotify
                debugPrint('No hay previsualización disponible. Abrir URL: ${widget.spotifyUrl}');
                
                // Convertir la cadena a Uri
                final Uri spotifyUri = Uri.parse(widget.spotifyUrl);
                
                // Intentar abrir la URL
                try {
                  if (await canLaunchUrl(spotifyUri)) {
                    await launchUrl(
                      spotifyUri, 
                      mode: LaunchMode.externalApplication,  // Abrir en la app de Spotify o en el navegador
                    );
                  } else {
                    debugPrint('No se puede abrir la URL: ${widget.spotifyUrl}');
                  }
                } catch (e) {
                  debugPrint('Error al abrir la URL: $e');
                }
              }
            },
          ),
          
          // Indicador visual de si hay previsualización disponible
          if (widget.previewUrl == null || widget.previewUrl!.isEmpty)
            Positioned(
              right: 7,
              bottom: 7,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Construye la fila con el sistema de calificación
  Widget _buildRatingRow(Duration animationDuration, Curve animationCurve, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, top: 6, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Alineado a la derecha
        children: [
          // Sistema de rating ahora a la derecha
          SizedBox(
            width: 170, 
            child: _buildRatingSystem(animationDuration, animationCurve),
          ),
        ],
      ),
    );
  }
  
  // Construye el sistema de calificación con estrellas y botón de confirmación
  Widget _buildRatingSystem(Duration animationDuration, Curve animationCurve) {
    return Stack(
      alignment: Alignment.centerRight, // Alineación a la derecha
      clipBehavior: Clip.none,
      children: [
        // Estrellas de calificación con animación
        AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          transform: Matrix4.translationValues(
            _expanded ? -30.0 : 0.0, 0, 0,
          ),
          child: Rating(
            rating: _currentRating,
            itemSize: 20, // Tamaño ligeramente mayor para mejor visibilidad
            rateable: true,
            onRatingUpdate: _handleRatingUpdate,
          ),
        ),
        
        // Botón de confirmación
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: animationCurve,
            width: _expanded ? 34.0 : 0.0,
            decoration: BoxDecoration(
              color: CorporativeColors.mainColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: _expanded ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ] : null,
            ),
            child: _expanded
                ? Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: CorporativeColors.whiteColor,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _handleRatingConfirmation,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
