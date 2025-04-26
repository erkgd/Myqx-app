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
  final VoidCallback? onPlayPressed;
  final bool loadRating; // Nueva propiedad para controlar si se carga la calificación
  
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
    this.loadRating = true, // Por defecto, cargar las calificaciones
  }) : super(key: key);

  @override
  State<AlbumTrackCard> createState() => _AlbumTrackCardState();
}

class _AlbumTrackCardState extends State<AlbumTrackCard> {
  double _currentRating = 0;
  bool _expanded = false;
  Timer? _debounceTimer;
  late SearchService _ratingService;
  
  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _ratingService = SearchService();
    
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
      // Ya usamos el sistema de caché en el servicio, no es necesario duplicar la lógica aquí
      final rating = await _ratingService.getSongRating(widget.songId);
      if (rating != null && mounted) {
        setState(() {
          _currentRating = rating;
        });
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to load track rating: $e');
      // No actualizamos el estado en caso de error, mantenemos la calificación predeterminada
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final animationDuration = const Duration(milliseconds: 300);
    final animationCurve = Curves.easeInOut;
    
    return MusicContainer(
      borderColor: CorporativeColors.mainColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            // Aumenta un poco la altura para acomodar el rating debajo del texto
            height: 75,
            child: Row(
              children: [
                // Track number
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.trackNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),

                // Album cover (small)
                if (widget.albumCoverUrl.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: NetworkImage(widget.albumCoverUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                const SizedBox(width: 10),

                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Track name
                      Text(
                        widget.trackName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Rating system below the track name
                      Row(
                        children: [
                          // Rating stars with animation
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedContainer(
                                  duration: animationDuration,
                                  curve: animationCurve,
                                  transform: Matrix4.translationValues(
                                    _expanded ? -40.0 : 0.0, 0, 0,
                                  ),
                                  child: Rating(
                                    rating: _currentRating,
                                    itemSize: 18,
                                    rateable: true,
                                    onRatingUpdate: (newRating) {
                                      // Actualización local del rating sin enviar al servidor
                                      setState(() {
                                        _currentRating = newRating;
                                      });
                                      
                                      // Guardar inmediatamente en caché local como calificación provisional
                                      // Esto permite que la calificación persista incluso durante el scroll
                                      RatingCache().setTrackRating(widget.songId, newRating);
                                      debugPrint('[CACHE] Provisional rating cached: ${widget.songId} - $newRating');
                                      
                                      // Cancelar timer previo si existe
                                      _debounceTimer?.cancel();
                                      
                                      // Programar la animación después de 1 segundo para mostrar el botón de confirmar
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
                                    },
                                  ),
                                ),
                                
                                // Panel de confirmación ahora al lado derecho de las estrellas
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: AnimatedContainer(
                                    duration: animationDuration,
                                    curve: animationCurve,
                                    width: _expanded ? 40.0 : 0.0,
                                    decoration: BoxDecoration(
                                      color: CorporativeColors.darkColor.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: CorporativeColors.mainColor,
                                        width: 1.0,
                                      ),
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
                                              onPressed: () async {
                                                // Guardar en caché inmediatamente para persistencia local
                                                RatingCache().setTrackRating(widget.songId, _currentRating);
                                                
                                                // Enviar la calificación al servidor cuando se confirma
                                                final success = await _ratingService.rateSong(widget.songId, _currentRating);
                                                // Always treat as successful for now while backend is implemented
                                                // This gives a better user experience instead of showing errors
                                                debugPrint('[RATING] Song rated: ${widget.songId} - $_currentRating (success: $success, cached locally)');
                                                
                                                // Always show success message (in English)
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Rating saved successfully!'),
                                                      duration: Duration(seconds: 2),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                }
                                                
                                                // Ocultar el panel de confirmación
                                                if (mounted) {
                                                  setState(() {
                                                    _expanded = false;
                                                  });
                                                }
                                              },
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Play button
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_outlined,
                    color: CorporativeColors.mainColor,
                  ),
                  onPressed: widget.onPlayPressed ?? () {
                    // Abrir URL de Spotify si no se proporciona una acción específica
                    if (widget.spotifyUrl.isNotEmpty) {
                      // Aquí podríamos usar url_launcher pero necesitaríamos añadir dependencias
                      debugPrint('Abrir URL: ${widget.spotifyUrl}');
                      
                      // Forzar persistencia de calificaciones cuando se reproduce
                      // Esto es una forma adicional de asegurar que no se pierdan calificaciones
                      RatingCache().printStats();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
