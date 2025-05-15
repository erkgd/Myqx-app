import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/search_service.dart';
import 'package:myqx_app/core/utils/rating_cache.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';

class AlbumTrackCard extends StatefulWidget {
  final int trackNumber;
  final String trackName;
  final String albumCoverUrl;
  final String spotifyUrl;
  final String songId;
  final double rating;
  final Function(double)? onRatingChanged;
  final bool loadRating;
  final String? artistName;
  
  const AlbumTrackCard({
    Key? key,
    required this.trackNumber,
    required this.trackName,
    required this.albumCoverUrl,
    required this.spotifyUrl,
    required this.songId,
    this.rating = 0.0,
    this.onRatingChanged,
    this.loadRating = true,
    this.artistName,
  }) : super(key: key);

  @override
  State<AlbumTrackCard> createState() => _AlbumTrackCardState();
}

class _AlbumTrackCardState extends State<AlbumTrackCard> {
  double _currentRating = 0;
  bool _expanded = false;
  bool _showRating = false; // Variable para controlar la visibilidad del sistema de rating
  Timer? _debounceTimer;
  late SearchService _ratingService;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _ratingService = SearchService();
    _loadCachedOrServerRating();
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: _buildSingleLineContent(isSmallScreen, animationDuration, animationCurve),
      ),
    );
  }
    // Construye el contenido completo en una sola línea
  Widget _buildSingleLineContent(bool isSmallScreen, Duration animationDuration, Curve animationCurve) {
    return SizedBox(
      height: 48, // Altura reducida para una sola línea
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Número de pista
          _buildTrackNumber(),
          
          // Carátula del álbum
          _buildAlbumCover(),
          
          const SizedBox(width: 12),
          
          // Información de la pista (título y artista)
          _buildTrackDetails(isSmallScreen),
          
          // Botón para mostrar/ocultar el sistema de rating
          _buildRatingToggleButton(animationDuration, animationCurve),
          
          // Sistema de rating con botón de confirmación (visible solo si _showRating es true)
          if (_showRating)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildRatingSystem(animationDuration, animationCurve),
            ),
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
    // Obtener el nombre del artista
    final artistName = _getArtistName();
    final bool showArtist = artistName != "Unknown Artist";
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nombre de la pista (con más espacio cuando el rating está oculto)
          Text(
            widget.trackName,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Nombre del artista (solo si no es "Unknown Artist")
          if (showArtist)
            Text(
              artistName,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.normal,
                color: Colors.grey[400],
              ),
              maxLines: 1,
              // Más espacio para el texto cuando el rating está oculto
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
    // Construye el sistema de calificación con estrellas y botón de confirmación con animación mejorada
  Widget _buildRatingSystem(Duration animationDuration, Curve animationCurve) {
    return AnimatedOpacity(
      opacity: _showRating ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          // Estrellas de calificación con animación
          AnimatedContainer(
            duration: animationDuration,
            curve: animationCurve,
            transform: Matrix4.translationValues(
              _expanded ? -24.0 : 0.0, 0, 0,
            ),
            child: Rating(
              rating: _currentRating,
              itemSize: 16, // Tamaño reducido para una sola línea
              rateable: true,
              onRatingUpdate: _handleRatingUpdate,
            ),
          ),
          
          // Botón de confirmación con animación mejorada
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: animationCurve,
              width: _expanded ? 28.0 : 0.0,
              decoration: BoxDecoration(
                color: CorporativeColors.mainColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
                boxShadow: _expanded ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 3,
                    spreadRadius: 1,
                  )
                ] : null,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _expanded ? 1.0 : 0.0,
                child: _expanded
                  ? Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: CorporativeColors.whiteColor,
                          size: 14,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _handleRatingConfirmation,
                      ),
                    )
                  : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
    // Construye el botón para mostrar/ocultar el sistema de calificación
  Widget _buildRatingToggleButton(Duration animationDuration, Curve animationCurve) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: CorporativeColors.mainColor.withOpacity(0.3),
          highlightColor: CorporativeColors.mainColor.withOpacity(0.1),
          child: Container(
            width: 30,
            height: 30,
            padding: EdgeInsets.zero,            child: Center(
              child: AnimatedOpacity(
                opacity: _expanded ? 0.0 : 1.0, // Desaparece cuando se muestra el botón de confirmar
                duration: const Duration(milliseconds: 150),
                child: AnimatedRotation(
                  duration: animationDuration,
                  curve: animationCurve,
                  turns: _showRating ? 0.25 : 0, // Gira 90 grados (0.25 vueltas)
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: _showRating ? CorporativeColors.mainColor : Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),          onTap: () {
            setState(() {
              // Solo permitimos cambiar el estado si no hay confirmación pendiente
              if (!_expanded) {
                _showRating = !_showRating;
                // Si acabamos de ocultar el rating, también ocultamos el botón de confirmación
                if (!_showRating) {
                  _expanded = false;
                }
              } else {
                // Si hay una confirmación pendiente, solo permitimos ocultar
                if (_showRating) {
                  _showRating = false;
                  _expanded = false;
                }
              }
            });
          },
        ),
      ),
    );
  }
}
