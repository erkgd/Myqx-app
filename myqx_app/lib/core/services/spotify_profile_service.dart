import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/constants/spotify_constants.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myqx_app/data/models/spotify_artist.dart';

class SpotifyProfileService with ChangeNotifier {
  // Implementación del patrón singleton
  static final SpotifyProfileService _instance = SpotifyProfileService._internal();
  factory SpotifyProfileService() => _instance;
  SpotifyProfileService._internal();
  
  final SpotifyAuthService _authService = SpotifyAuthService();
  
  SpotifyUser? _currentUser;
  List<SpotifyTrack> _topTracks = [];
  List<SpotifyAlbum> _topAlbums = [];
  List<SpotifyArtist> _topArtists = [];
  SpotifyTrack? _starOfTheDay;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  SpotifyUser? get currentUser => _currentUser;
  List<SpotifyTrack> get topTracks => _topTracks;
  List<SpotifyAlbum> get topAlbums => _topAlbums;
  List<SpotifyArtist> get topArtists => _topArtists;
  SpotifyTrack? get starOfTheDay => _starOfTheDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialize the service and load data
  Future<void> initialize({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      // Si no estamos forzando actualización, intentamos cargar datos guardados
      if (!forceRefresh) {
        final dataLoaded = await _loadDataFromPreferences();
        
        // Si tenemos datos y no necesitamos actualizar, terminamos
        if (dataLoaded && !await _needsRefresh()) {
          _setLoading(false);
          return;
        }
      }
      
      // Si llegamos aquí, necesitamos cargar datos de la API
      await _loadUserProfile();
      await Future.wait([
        _loadTopTracks(),
        _loadTopAlbums(),
        _loadTopArtists(),
      ]);
      _pickStarOfTheDay();
      
      // Guardar datos en SharedPreferences
      await _saveDataToPreferences();
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load profile data: ${e.toString()}";
      debugPrint("[ERROR] SpotifyProfileService: $_errorMessage");
    } finally {
      _setLoading(false);
    }
  }
  
  // Verificar si los datos necesitan actualizarse
  Future<bool> _needsRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt('spotify_last_update') ?? 0;
    
    // Actualizar datos si tienen más de 2 horas
    final twoHoursInMillis = 2 * 60 * 60 * 1000;
    return DateTime.now().millisecondsSinceEpoch - lastUpdate > twoHoursInMillis;
  }
  
  // Cargar datos desde SharedPreferences
  Future<bool> _loadDataFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar usuario
      final userJson = prefs.getString('spotify_user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = SpotifyUser.fromJson(userData);
      }
      
      // Cargar tracks
      final tracksJson = prefs.getString('spotify_top_tracks');
      if (tracksJson != null) {
        final List<dynamic> tracksData = json.decode(tracksJson);
        _topTracks = tracksData.map((track) => SpotifyTrack.fromJson(track)).toList();
      }
      
      // Cargar álbumes
      final albumsJson = prefs.getString('spotify_top_albums');
      if (albumsJson != null) {
        final List<dynamic> albumsData = json.decode(albumsJson);
        _topAlbums = albumsData.map((album) => SpotifyAlbum.fromJson(album)).toList();
      }
      
      // Cargar artistas
      final artistsJson = prefs.getString('spotify_top_artists');
      if (artistsJson != null) {
        final List<dynamic> artistsData = json.decode(artistsJson);
        _topArtists = artistsData.map((artist) => SpotifyArtist.fromJson(artist)).toList();
      }
      
      // Cargar estrella del día
      final starJson = prefs.getString('spotify_star_track');
      if (starJson != null) {
        _starOfTheDay = SpotifyTrack.fromJson(json.decode(starJson));
      }
      
      // Verificar si se cargaron todos los datos necesarios
      final dataComplete = _currentUser != null && 
                          _topTracks.isNotEmpty && 
                          _topAlbums.isNotEmpty &&
                          _topArtists.isNotEmpty &&
                          _starOfTheDay != null;
      
      if (dataComplete) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("[ERROR] Error loading data from SharedPreferences: $e");
      return false;
    }
  }
  
  // Guardar datos en SharedPreferences
  Future<void> _saveDataToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar usuario
      if (_currentUser != null) {
        await prefs.setString('spotify_user', json.encode(_currentUserToJson()));
      }
      
      // Guardar tracks
      if (_topTracks.isNotEmpty) {
        await prefs.setString('spotify_top_tracks', 
          json.encode(_topTracks.map((track) => _trackToJson(track)).toList()));
      }
      
      // Guardar álbumes
      if (_topAlbums.isNotEmpty) {
        await prefs.setString('spotify_top_albums', 
          json.encode(_topAlbums.map((album) => _albumToJson(album)).toList()));
      }
      
      // Guardar artistas
      if (_topArtists.isNotEmpty) {
        await prefs.setString('spotify_top_artists', 
          json.encode(_topArtists.map((artist) => _artistToJson(artist)).toList()));
      }
      
      // Guardar estrella del día
      if (_starOfTheDay != null) {
        await prefs.setString('spotify_star_track', json.encode(_trackToJson(_starOfTheDay!)));
      }
      
      // Guardar timestamp de última actualización
      await prefs.setInt('spotify_last_update', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint("[ERROR] Error saving data to SharedPreferences: $e");
    }
  }
  
  // Métodos auxiliares para convertir modelos a JSON
  Map<String, dynamic> _currentUserToJson() {
    return {
      'id': _currentUser!.id,
      'display_name': _currentUser!.displayName,
      'email': _currentUser!.email,
      'images': _currentUser!.imageUrl != null ? [{'url': _currentUser!.imageUrl}] : [],
      'external_urls': {'spotify': _currentUser!.spotifyUrl},
      'followers': {'total': _currentUser!.followers},
    };
  }
  
  Map<String, dynamic> _trackToJson(SpotifyTrack track) {
    return {
      'id': track.id,
      'name': track.name,
      'artists': [{'name': track.artistName}],
      'album': {
        'name': track.albumName,
        'images': track.imageUrl != null ? [{'url': track.imageUrl}] : [],
        'external_urls': {'spotify': track.spotifyUrl}
      },
      'external_urls': {'spotify': track.spotifyUrl}
    };
  }
  
  Map<String, dynamic> _albumToJson(SpotifyAlbum album) {
    return {
      'id': album.id,
      'name': album.name,
      'artists': [{'name': album.artistName}],
      'images': [{'url': album.coverUrl}],
      'external_urls': {'spotify': album.spotifyUrl}
    };
  }
  
  Map<String, dynamic> _artistToJson(SpotifyArtist artist) {
    return {
      'id': artist.id,
      'name': artist.name,
      'images': artist.imageUrl != null ? [{'url': artist.imageUrl}] : [],
      'external_urls': {'spotify': artist.spotifyUrl},
      'followers': {'total': artist.followers},
      'genres': artist.genres,
    };
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Load user profile from Spotify API
  Future<void> _loadUserProfile() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = SpotifyUser.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load user profile: $e");
      rethrow;
    }
  }
  
  // Load user's top tracks from Spotify API
  Future<void> _loadTopTracks() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me/top/tracks?limit=10&time_range=medium_term'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _topTracks = (data['items'] as List)
            .map((item) => SpotifyTrack.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load top tracks: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load top tracks: $e");
      rethrow;
    }
  }
  
  // Extract albums from top tracks and deduplicate
  Future<void> _loadTopAlbums() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me/top/tracks?limit=50&time_range=long_term'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracks = (data['items'] as List);
        
        // Extract unique albums from the tracks
        final Map<String, SpotifyAlbum> albumsMap = {};
        
        for (var track in tracks) {
          final album = track['album'];
          final albumId = album['id'];
          
          if (!albumsMap.containsKey(albumId)) {
            albumsMap[albumId] = SpotifyAlbum(
              id: albumId,
              name: album['name'],
              artistName: album['artists'][0]['name'],
              artistId: album['artists'][0]['id'],
              coverUrl: album['images']?[0]?['url'] ?? '',
              releaseDate: album['release_date'] ?? '',
              spotifyUrl: album['external_urls']['spotify'],
              totalTracks: album['total_tracks'] ?? 0,
            );
          }
        }
        
        // Convert map to list and take top 5
        _topAlbums = albumsMap.values.toList();
        _topAlbums.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically for now
        if (_topAlbums.length > 5) {
          _topAlbums = _topAlbums.sublist(0, 5);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load top albums: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load top albums: $e");
      rethrow;
    }
  }
    // Load user's top artists from Spotify API
  Future<void> _loadTopArtists() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me/top/artists?limit=10&time_range=medium_term'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;
        
        _topArtists = [];
        for (int i = 0; i < items.length; i++) {
          // En la API de Spotify, el orden de los resultados refleja cuánto 
          // escucha el usuario cada artista. Los primeros son los más escuchados.
          // Creamos un valor decreciente para representar las escuchas (10 para el primero, 9 para el segundo, etc)
          final item = items[i];
          final artistData = Map<String, dynamic>.from(item);          // Valores fijos y muy diferenciados para asegurar diferencias visuales claras
          // Damos valores con diferencias extremas: 10000, 4000, 1000
          if (i == 0) {
            artistData['userListeningCount'] = 10000;
          } else if (i == 1) {
            artistData['userListeningCount'] = 4000;
          } else {
            artistData['userListeningCount'] = 1000;
          }
          
          _topArtists.add(SpotifyArtist.fromJson(artistData));
        }
        
        // Ordenamos por mayor escucha (de mayor a menor)
        _topArtists.sort((a, b) => b.userListeningCount.compareTo(a.userListeningCount));
        
        notifyListeners();
      } else {
        throw Exception('Failed to load top artists: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load top artists: $e");
      rethrow;
    }
  }
  
  // Pick a random track as "star of the day"
  void _pickStarOfTheDay() {
    if (_topTracks.isNotEmpty) {
      // For now, just pick the first track as the star
      _starOfTheDay = _topTracks.first;
      notifyListeners();
    }
  }
  
  // Calculate compatibility with another user (placeholder for now)
  int calculateCompatibility() {
    // This would normally compare music tastes with another user
    // For now, return a random percentage
    return (DateTime.now().millisecond % 101); // 0-100
  }
}