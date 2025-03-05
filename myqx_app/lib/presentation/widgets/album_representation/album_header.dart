import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/presentation/widgets/spotify/music_cover.dart';
import 'package:myqx_app/presentation/widgets/broadcast/ratedmusicwidgets/rating.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';

class AlbumHeader extends StatefulWidget {
  final String albumTitle;
  final String artist;
  final String imageUrl;
  final String releaseYear;
  final double rating;
  final String spotifyUrl;
  final Function(double)? onRatingChanged;
  final Function(String)? onReviewSubmitted;

  const AlbumHeader({
    Key? key,
    required this.albumTitle,
    required this.artist,
    required this.imageUrl,
    required this.releaseYear,
    required this.rating,
    required this.spotifyUrl,
    this.onRatingChanged,
    this.onReviewSubmitted,
  }) : super(key: key);

  @override
  State<AlbumHeader> createState() => _AlbumHeaderState();
}

class _AlbumHeaderState extends State<AlbumHeader> {
  late double _currentRating;
  bool _ratingChanged = false;
  bool _expanded = false;
  Timer? _debounceTimer;
  
  // Para la reseña
  final TextEditingController _reviewController = TextEditingController();
  final int _maxReviewLength = 100;
  
  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
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
                                  rateable: true,
                                  onRatingUpdate: (newRating) {
                                    // Actualización local del rating
                                    setState(() {
                                      _currentRating = newRating;
                                      _ratingChanged = true;
                                    });
                                    
                                    // Cancelar timer previo si existe
                                    _debounceTimer?.cancel();
                                    
                                    // Programar la animación después de 2 segundos
                                    _debounceTimer = Timer(
                                      const Duration(seconds: 2), 
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
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          // Solo confirma el rating sin exigir una reseña
                                          // Envía la reseña si existe texto
                                          if (_reviewController.text.isNotEmpty) {
                                            widget.onReviewSubmitted?.call(_reviewController.text);
                                          }
                                          
                                          // Resetear estados
                                          setState(() {
                                            _expanded = false;
                                            _reviewController.clear();
                                          });
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

  @override
  Widget build(BuildContext context) {
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
                child: const Text('Cancel All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}