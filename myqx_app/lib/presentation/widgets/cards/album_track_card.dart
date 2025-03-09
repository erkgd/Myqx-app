import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myqx_app/core/constants/corporative_colors.dart';
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
  }) : super(key: key);

  @override
  State<AlbumTrackCard> createState() => _AlbumTrackCardState();
}

class _AlbumTrackCardState extends State<AlbumTrackCard> {
  double _currentRating = 0;
  bool _ratingChanged = false;
  bool _expanded = false;
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
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
          // Contenido principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Botón de Play
                IconButton(
                  icon: Icon(
                    Icons.play_circle_filled,
                    color: CorporativeColors.whiteColor,
                    size: isSmallScreen ? 18 : 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onPlayPressed ?? () {
                    debugPrint('Play button pressed for track: ${widget.trackName}');
                  },
                ),
                
                const SizedBox(width: 8),
                
                // 2. Número y nombre de la canción
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 18 : 20,
                        child: Text(
                          '${widget.trackNumber}.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: Text(
                          widget.trackName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Espacio para el rating que será posicionado en el Stack
                const SizedBox(width: 4),
              ],
            ),
          ),
          
          // Rating animado - ahora es parte del Stack y se mueve con el panel
          Positioned(
            right: _expanded ? 70.0 : 10.0, // Se mueve junto con el panel
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: animationCurve,
              alignment: Alignment.center,
              child: Rating(
                rating: _currentRating,
                itemSize: isSmallScreen ? 15 : 17,
                onRatingUpdate: (value) {
                  setState(() {
                    _currentRating = value;
                    _ratingChanged = true;
                  });
                  
                  // Cancelar el timer anterior si existe
                  _debounceTimer?.cancel();
                  
                  // Mostrar el panel después de un tiempo
                  _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
                    setState(() {
                      _expanded = true;
                    });
                  });
                  
                  if (widget.onRatingChanged != null) {
                    widget.onRatingChanged!(value);
                  }
                },
              ),
            ),
          ),
          
          // Sección desplegable
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: animationDuration, // Misma duración para ambas animaciones
              curve: animationCurve, // Misma curva para ambas animaciones
              width: _expanded ? 60.0 : 0.0,
              decoration: BoxDecoration(
                color: CorporativeColors.darkColor.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
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
                        setState(() {
                          _expanded = false;
                        });
                      },
                    ),
                  )
                : null,
            ),
          ),
        ],
      ),
    );
  }
}