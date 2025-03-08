import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/album_representation/album_header.dart';
import 'package:myqx_app/presentation/widgets/album_representation/album_track_card.dart';
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
    
    // Si se proporcionó un ID, cargar datos completos
    if (widget.albumId != null) {
      _loadAlbumDetails();
      _loadAlbumTracks();
    }
    
  }

  Future<void> _loadAlbumDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final albumService = SpotifyAlbumService();
      final albumDetails = await albumService.getAlbumDetails(widget.albumId!);
      print(albumDetails.tracks);
      setState(() {
        _albumTitle = albumDetails.name;
        _artist = albumDetails.artistName;
        _imageUrl = albumDetails.coverUrl;
        _releaseYear = _extractYear(albumDetails.releaseDate);
        _rating = albumDetails.rating ?? 0.0;
        _spotifyUrl = albumDetails.spotifyUrl;
        _trackList = albumDetails.tracks?.map((t) => t.name).toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading album details: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadAlbumTracks() async {
    SpotifyAlbumService albumService = SpotifyAlbumService();
    try {
      final tracks = await albumService.getAlbumTracks(widget.albumId!);
      setState(() {
        _trackList = tracks.map((t) => t.name).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading album tracks: $e';
      });
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
                    // Aquí puedes guardar el nuevo rating
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