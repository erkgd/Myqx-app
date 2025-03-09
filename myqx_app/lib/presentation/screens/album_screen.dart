import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/cards/album_header.dart';
import 'package:myqx_app/presentation/widgets/cards/album_track_card.dart';
import 'package:myqx_app/core/services/spotify_album_service.dart'; 

class AlbumScreen extends StatefulWidget {
  final String? albumId;
  final String albumTitle;
  final String artist;
  final String imageUrl;
  final String releaseYear;
  final double rating;
  final List<String> trackList;
  final String spotifyUrl;

  // Constructor principal con todos los datos
  const AlbumScreen({
    Key? key,
    this.albumId,
    required this.albumTitle,
    required this.artist,
    required this.imageUrl,
    required this.releaseYear,
    required this.rating,
    required this.trackList,
    required this.spotifyUrl,
  }) : super(key: key);
  
  // Constructor nombrado para crear desde ID
  factory AlbumScreen.fromId({
    required String albumId,
  }) {
    return AlbumScreen(
      albumId: albumId,
      albumTitle: '', // Se cargará con los datos
      artist: '',
      imageUrl: '',
      releaseYear: '',
      rating: 0.0,
      trackList: const [],
      spotifyUrl: '',
    );
  }

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Datos que pueden ser cargados de la API
  late String _albumTitle;
  late String _artist;
  late String _imageUrl;
  late String _releaseYear;
  late double _rating;
  late String _spotifyUrl;
  late List<String> _trackList;

  @override
void initState() {
  super.initState();
  
  // Inicializar con los valores proporcionados
  _albumTitle = widget.albumTitle;
  _artist = widget.artist;
  _imageUrl = widget.imageUrl;
  _releaseYear = widget.releaseYear;
  _rating = widget.rating;
  _spotifyUrl = widget.spotifyUrl;
  _trackList = widget.trackList;
  
  // Cargar secuencialmente (primero detalles, luego tracks si es necesario)
  if (widget.albumId != null && widget.albumId!.isNotEmpty) {
    _loadAllData();
  }
}

  Future<void> _loadAllData() async {
    // Usar try/catch general para manejar cualquier error
    try {
      // Primero cargar detalles del álbum
      await _loadAlbumDetails();
      
      // Si no hay tracks después de cargar detalles, intentar con tracks específicos
      if (_trackList.isEmpty) {
        debugPrint("⚠️ No se obtuvieron tracks de los detalles, cargando específicamente...");
        await _loadAlbumTracks();
      }
    } catch (e) {
      debugPrint("Error en carga secuencial: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading album: $e';
        });
      }
    }
  }

  Future<void> _loadAlbumDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final albumService = SpotifyAlbumService();
      final albumDetails = await albumService.getAlbumDetails(widget.albumId!)
          .timeout(const Duration(seconds: 15));
      
      debugPrint("Detalles del álbum cargados: ${albumDetails.name}");
      debugPrint("Tracks en detalles: ${albumDetails.tracks?.length ?? 0}");
      
      if (mounted) {
        setState(() {
          _albumTitle = albumDetails.name;
          _artist = albumDetails.artistName;
          _imageUrl = albumDetails.coverUrl;
          _releaseYear = _extractYear(albumDetails.releaseDate);
          _rating = albumDetails.rating ?? 0.0;
          _spotifyUrl = albumDetails.spotifyUrl;
          
          // Si hay tracks en los detalles, usarlos
          if (albumDetails.tracks != null && albumDetails.tracks!.isNotEmpty) {
            _trackList = albumDetails.tracks!.map((t) => t.name).toList();
            debugPrint("✅ Se asignaron ${_trackList.length} tracks de detalles");
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error en detalles: $e");
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading album details: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAlbumTracks() async {
    if (!mounted) return;
    
    try {
      final albumService = SpotifyAlbumService();
      final tracks = await albumService.getAlbumTracks(widget.albumId!)
          .timeout(const Duration(seconds: 15));
      
      debugPrint("Tracks específicos cargados: ${tracks.length}");
      
      if (mounted && tracks.isNotEmpty) {
        setState(() {
          _trackList = tracks.map((t) => t.name).toList();
          debugPrint("e asignaron ${_trackList.length} tracks de endpoint específico");
        });
      }
    } catch (e) {
      debugPrint("Error cargando tracks específicos: $e");
      // No mostrar este error al usuario si ya tenemos datos básicos del álbum
    }
  }
  String _extractYear(String releaseDate) {
    // Extraer el año de la fecha (formato YYYY-MM-DD)
    if (releaseDate.isNotEmpty && releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se recuperan los datos
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const UserHeader(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Mostrar mensaje de error si algo falló
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const UserHeader(),
        body: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    
    // Mostrar contenido normal
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const UserHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget separado para la cabecera del álbum
            AlbumHeader(
              albumId: widget.albumId ?? '',
              albumTitle: _albumTitle,
              artist: _artist,
              imageUrl: _imageUrl,
              releaseYear: _releaseYear,
              rating: _rating,
              spotifyUrl: _spotifyUrl,
              
            ),
            
            const SizedBox(height: 20),
            
            // Lista de tracks con widget separado para cada canción
            ..._trackList.asMap().entries.map((entry) {
              final index = entry.key;
              final track = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: AlbumTrackCard(
                  trackNumber: index + 1,
                  trackName: track,
                  albumCoverUrl: _imageUrl,
                  spotifyUrl: '$_spotifyUrl?track=${index+1}',
                  songId: 'track_$index',
                  rating: 4.0,
                  onRatingChanged: (newRating) {
                    print('Nueva calificación para $track: $newRating');
                  },
                )
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}