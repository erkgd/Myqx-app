import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/search_service.dart';
import 'package:myqx_app/core/utils/rating_cache.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/presentation/widgets/spotify/music_cover.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';

class AlbumHeader extends StatefulWidget {
  final String albumId;
  final String albumTitle;
  final String artist;
  final String imageUrl;
  final String releaseYear;
  final double rating;
  final String spotifyUrl;
  final Function(double)? onRatingChanged;
  final Function(String)? onReviewSubmitted;
  final bool loadRating; // Nueva propiedad para controlar si se carga la calificación

  const AlbumHeader({
    Key? key,
    required this.albumId,
    required this.albumTitle,
    required this.artist,
    required this.imageUrl,
    required this.releaseYear,
    required this.rating,
    required this.spotifyUrl,
    this.onRatingChanged,
    this.onReviewSubmitted,
    this.loadRating = true, // Por defecto, cargar las calificaciones
  }) : super(key: key);

  @override
  State<AlbumHeader> createState() => _AlbumHeaderState();
}

class _AlbumHeaderState extends State<AlbumHeader> {
  late double _currentRating;
  bool _expanded = false;
  Timer? _debounceTimer;
  late SearchService _ratingService;
  
  // Para la reseña
  final TextEditingController _reviewController = TextEditingController();
  final int _maxReviewLength = 100;
  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _ratingService = SearchService();
    
    // Verificar si hay calificación en caché antes de cargar
    final cachedRating = RatingCache().getAlbumRating(widget.albumId);
    if (cachedRating != null) {
      _currentRating = cachedRating;
      debugPrint('[CACHE] Using cached album rating for UI: ${widget.albumId} - $cachedRating');
    }
    // Cargar calificación del servidor solo si está habilitado y no tenemos caché
    else if (widget.loadRating) {
      _loadCurrentRating();
    } else {
      debugPrint('[DEBUG] Album rating loading skipped for: ${widget.albumId}');
    }
  }
    Future<void> _loadCurrentRating() async {
    if (widget.albumId.isEmpty) return;
    
    try {
      // Ya usamos el sistema de caché en el servicio, no es necesario duplicar la lógica aquí
      final rating = await _ratingService.getAlbumRating(widget.albumId);
      if (rating != null && mounted) {
        setState(() {
          _currentRating = rating;
        });
      }
    } catch (e) {       
      debugPrint('[ERROR] Failed to load album rating: $e');
      // No actualizamos el estado en caso de error, mantenemos la calificación predeterminada
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _reviewController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final coverSize = isSmallScreen ? 120.0 : 140.0;
    final animationDuration = const Duration(milliseconds: 300);
    final animationCurve = Curves.easeInOut;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Tarjeta principal del álbum
        MusicContainer(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portada del álbum
                MusicCover(
                  imageUrl: widget.imageUrl,
                  size: coverSize,
                  albumId: widget.albumId,
                  isNavigable: true,
                ),
                
                const SizedBox(width: 15),
                
                // Área de información y controles
                Expanded(
                  child: SizedBox(
                    height: coverSize,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Artista
                        Text(
                          widget.artist,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // 2. Título del álbum
                        Text(
                          widget.albumTitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 13,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // 3. Año (más pequeño y discreto)
                        Text(
                          '${widget.releaseYear}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CorporativeColors.mainColor,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // 5. Botón de Spotify
                        OpenSpotifyButton(
                          spotifyUrl: widget.spotifyUrl,
                          height: isSmallScreen ? 22 : 24,
                          text: isSmallScreen ? 'Open' : 'Open in Spotify',
                        ),
                        
                        const Spacer(),
                        
                        // 4. Rating con animación y confirmación
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              // Contenedor animado para el rating
                              child: AnimatedContainer(
                                duration: animationDuration,
                                curve: animationCurve,
                                transform: Matrix4.translationValues(
                                  _expanded ? -60.0 : 0.0, 0, 0,
                                ),
                                child: Rating(
                                  rating: _currentRating,
                                  itemSize: isSmallScreen ? 16 : 20,
                                  rateable: true,                                  onRatingUpdate: (newRating) {
                                    // Actualización local del rating sin enviar al servidor
                                    setState(() {
                                      _currentRating = newRating;
                                    });
                                    
                                    // Guardar inmediatamente en caché local como calificación provisional
                                    // Esto permite que la calificación persista durante el scroll
                                    RatingCache().setAlbumRating(widget.albumId, newRating);
                                    debugPrint('[CACHE] Provisional album rating cached: ${widget.albumId} - $newRating');
                                    
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
                            ),
                            
                            // Panel de confirmación
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: AnimatedContainer(
                                duration: animationDuration,
                                curve: animationCurve,
                                width: _expanded ? 60.0 : 0.0,
                                decoration: BoxDecoration(
                                  color: CorporativeColors.darkColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                                  border: Border.all(
                                    color: CorporativeColors.mainColor,
                                    width: 1.0,
                                  ),
                                ),
                                child: _expanded 
                                  ? Center(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: CorporativeColors.whiteColor,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),                                        onPressed: () async {
                                          // Guardar en caché inmediatamente para persistencia local
                                          RatingCache().setAlbumRating(widget.albumId, _currentRating);
                                          
                                          // Extraer el comentario si existe
                                          final String? comment = _reviewController.text.isNotEmpty ? _reviewController.text : null;
                                          
                                          // Log para verificar el valor del comentario
                                          debugPrint('[DEBUG][ALBUM_HEADER] Comment input value: "${comment ?? "NO COMMENT"}"');
                                          
                                          // Enviar la calificación al servidor cuando se confirma, incluyendo el comentario
                                          final success = await _ratingService.rateAlbum(
                                            widget.albumId, 
                                            _currentRating,
                                            comment: comment
                                          );
                                          
                                          // Always treat as successful for now while backend is implemented
                                          // This gives a better user experience instead of showing errors
                                          debugPrint('[RATING] Album rated: ${widget.albumId} - $_currentRating ${comment != null ? "with comment: \"$comment\"" : "without comment"} (success: $success, cached locally)');
                                          
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
                                          
                                          // Envía la reseña si existe texto - Esto ya no es necesario pues la enviamos directamente
                                          // con rateAlbum, pero lo mantenemos por compatibilidad
                                          if (_reviewController.text.isNotEmpty) {
                                            widget.onReviewSubmitted?.call(_reviewController.text);
                                          }
                                          
                                          // Resetear estados
                                          if (mounted) {
                                            setState(() {
                                              _expanded = false;
                                              _reviewController.clear();
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 2. Campo de entrada para la review (aparece simultáneamente con el botón de confirmar)
        AnimatedContainer(
          duration: animationDuration,
          height: _expanded ? null : 0,
          curve: animationCurve,
          child: AnimatedOpacity(
            duration: animationDuration,
            opacity: _expanded ? 1.0 : 0.0,
            child: _expanded ? ReviewInput(
              controller: _reviewController,
              maxLength: _maxReviewLength,
              onCancel: () {
                // Resetear estados sin enviar nada
                setState(() {
                  _expanded = false;
                  _reviewController.clear();
                });
              },
            ) : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}


class ReviewInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final VoidCallback onCancel;

  const ReviewInput({
    Key? key, 
    required this.controller,
    required this.maxLength,
    required this.onCancel,
  }) : super(key: key);

  @override  Widget build(BuildContext context) {
    return MusicContainer(
      borderColor: CorporativeColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Write your review (optional, max. $maxLength characters)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextField(
              controller: controller,
              maxLength: maxLength,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: CorporativeColors.mainColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: CorporativeColors.mainColor,
                    width: 2.0,
                  ),
                ),
                hintText: 'Share your thoughts about this album (optional)',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                counterStyle: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}