import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/data/models/spotify_models.dart';

class UnaffiliatedProfileService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  
  // Estado observable
  SpotifyUser? _profileUser;
  List<SpotifyAlbum> _topAlbums = [];
  SpotifyTrack? _starOfTheDay;
  bool _isLoading = false;
  String? _errorMessage;
  double _compatibility = 0.0;

  // Getters para acceder al estado
  SpotifyUser? get profileUser => _profileUser;
  List<SpotifyAlbum> get topAlbums => _topAlbums;
  SpotifyTrack? get starOfTheDay => _starOfTheDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get compatibility => _compatibility;

  UnaffiliatedProfileService({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
  }) : 
    _apiClient = apiClient ?? ApiClient(),
    _secureStorage = secureStorage ?? SecureStorage();

  // Método para cargar datos de perfil por ID de usuario
  Future<void> loadProfileById(String userId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('[DEBUG] Cargando perfil no afiliado con ID: $userId');
      
      final response = await _apiClient.get('/users/$userId/profile');
      
      // Log completo para depuración
      debugPrint('[DEBUG] Respuesta completa del perfil: ${response.toString()}');
      
      // Verificar si la respuesta tiene la estructura esperada
      if (response['data'] != null) {
        debugPrint('[DEBUG] Usando datos del campo "data" de la respuesta');
        final data = response['data'];
        
        // Procesar datos básicos del usuario
        if (data['user'] != null) {
          _profileUser = SpotifyUser(
            id: data['user']?['spotifyId'] ?? '',
            displayName: data['user']?['username'] ?? data['username'] ?? 'Usuario',
            email: null,
            imageUrl: data['user']?['profileImage'] ?? data['profileImage'],
            spotifyUrl: data['user']?['spotifyUrl'] ?? 'https://open.spotify.com/',
            followers: 0,
          );
        } else {
          // Intentar con la estructura directa si no hay 'user' en 'data'
          _profileUser = SpotifyUser(
            id: data['spotifyId'] ?? '',
            displayName: data['username'] ?? 'Usuario',
            email: null,
            imageUrl: data['profileImage'],
            spotifyUrl: data['spotifyUrl'] ?? 'https://open.spotify.com/',
            followers: 0,
          );
        }
        
        // Procesar álbumes
        _topAlbums = [];
        if (data['top_albums'] != null) {
          debugPrint('[DEBUG] Procesando ${data['top_albums'].length} álbumes');
          for (final album in data['top_albums']) {
            _topAlbums.add(SpotifyAlbum(
              id: album['id'] ?? '',
              name: album['name'] ?? 'Unknown Album',
              artistName: album['artist_name'] ?? 'Unknown Artist',
              artistId: album['artist_id'] ?? '',
              coverUrl: album['image_url'] ?? '',
              releaseDate: album['release_date'] ?? '2025-01-01',
              totalTracks: album['total_tracks'] ?? 1,
              spotifyUrl: album['spotify_url'] ?? '',
            ));
          }
        }
        
        // Procesar canción destacada del día
        if (data['star_track'] != null) {
          final track = data['star_track'];
          debugPrint('[DEBUG] Procesando canción destacada: ${track['name'] ?? 'Unknown'}');
          try {
            _starOfTheDay = SpotifyTrack(
              id: track['id'] ?? '',
              name: track['name'] ?? 'Unknown Track',
              artistName: track['artist_name'] ?? 'Unknown Artist',
              albumName: track['album_name'] ?? '',
              imageUrl: track['image_url'] ?? '',
              spotifyUrl: track['spotify_url'] ?? '',
              albumId: track['album_id'], // Parámetro opcional
            );
          } catch (e) {
            debugPrint('[ERROR] Error al crear SpotifyTrack: $e');
            _starOfTheDay = null;
          }
        }
        
        // Procesar compatibilidad
        _compatibility = data['compatibility']?.toDouble() ?? 0.0;
        
      } else {
        // Si no hay campo 'data' en la respuesta, intentar procesar directamente
        debugPrint('[DEBUG] Estructura de respuesta inesperada, intentando procesar directamente');
        _processDirectResponse(response);
      }
      
      debugPrint('[DEBUG] Perfil no afiliado cargado con éxito');
    } catch (e) {
      debugPrint('[ERROR] Error al cargar perfil no afiliado: ${e.toString()}');
      _errorMessage = 'Error al cargar los datos del perfil: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para comprobar si el usuario actual sigue al usuario del perfil
  Future<bool> isFollowing(String userId) async {
    try {
      final response = await _apiClient.get('/users/following/status/$userId');
      debugPrint('[DEBUG] Estado de seguimiento: ${response.toString()}');
      return response['is_following'] ?? false;
    } catch (e) {
      debugPrint('[ERROR] Error al verificar si sigue al usuario: ${e.toString()}');
      return false;
    }
  }
    // Método para seguir a un usuario
  Future<bool> followUser(String userId) async {
    try {
      // Obtener el ID del usuario actual
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('[ERROR] No se pudo obtener el ID del usuario actual para seguir');
        return false;
      }
      
      // Usar el formato correcto de la ruta: /users/following/{id_follower}/{id_followed}
      final response = await _apiClient.post('/users/following/$currentUserId/$userId');
      
      debugPrint('[DEBUG] Petición de seguir enviada a: /users/following/$currentUserId/$userId');
      debugPrint('[DEBUG] Respuesta del servidor: ${response.toString()}');
      
      return response['success'] ?? false;
    } catch (e) {
      debugPrint('[ERROR] Error al seguir al usuario: ${e.toString()}');
      _errorMessage = 'No se pudo seguir al usuario: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Método para dejar de seguir a un usuario
  Future<bool> unfollowUser(String userId) async {
    try {
      // Obtener el ID del usuario actual
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('[ERROR] No se pudo obtener el ID del usuario actual para dejar de seguir');
        return false;
      }
      
      // Usar el formato correcto de la ruta: /users/following/{id_follower}/{id_followed}
      final response = await _apiClient.delete('/users/following/$currentUserId/$userId');
      
      debugPrint('[DEBUG] Petición de dejar de seguir enviada a: /users/following/$currentUserId/$userId');
      debugPrint('[DEBUG] Respuesta del servidor: ${response.toString()}');
      
      return response['success'] ?? false;
    } catch (e) {
      debugPrint('[ERROR] Error al dejar de seguir al usuario: ${e.toString()}');
      _errorMessage = 'No se pudo dejar de seguir al usuario: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Método para calcular compatibilidad
  double calculateCompatibility() {
    return _compatibility;
  }
  
  // Método para limpiar todos los datos
  void clear() {
    _profileUser = null;
    _topAlbums = [];
    _starOfTheDay = null;
    _errorMessage = null;
    _compatibility = 0.0;
    notifyListeners();
  }
  
  // Método para procesar la respuesta cuando viene en formato directo (sin campo 'data')
  void _processDirectResponse(Map<String, dynamic> response) {
    try {
      // Procesar usuario
      if (response['user'] != null) {
        _profileUser = SpotifyUser(
          id: response['user']['spotifyId'] ?? '',
          displayName: response['user']['username'] ?? 'Usuario',
          email: null,
          imageUrl: response['user']['profileImage'],
          spotifyUrl: response['user']['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      } else if (response['username'] != null) {
        _profileUser = SpotifyUser(
          id: response['spotifyId'] ?? '',
          displayName: response['username'] ?? 'Usuario',
          email: null,
          imageUrl: response['profileImage'],
          spotifyUrl: response['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      }
      
      // Procesar álbumes
      _topAlbums = [];
      if (response['top_albums'] != null) {
        for (final album in response['top_albums']) {
          _topAlbums.add(SpotifyAlbum(
            id: album['id'] ?? '',
            name: album['name'] ?? 'Unknown Album',
            artistName: album['artist_name'] ?? 'Unknown Artist',
            artistId: album['artist_id'] ?? '',
            coverUrl: album['image_url'] ?? '',
            releaseDate: album['release_date'] ?? '2025-01-01',
            totalTracks: album['total_tracks'] ?? 1,
            spotifyUrl: album['spotify_url'] ?? '',
          ));
        }
      }
      
      // Procesar canción destacada
      if (response['star_track'] != null) {
        final track = response['star_track'];
        try {
          _starOfTheDay = SpotifyTrack(
            id: track['id'] ?? '',
            name: track['name'] ?? 'Unknown Track',
            artistName: track['artist_name'] ?? 'Unknown Artist',
            albumName: track['album_name'] ?? '',
            imageUrl: track['image_url'] ?? '',
            spotifyUrl: track['spotify_url'] ?? '',
            albumId: track['album_id'],
          );
        } catch (e) {
          debugPrint('[ERROR] Error al crear SpotifyTrack: $e');
          _starOfTheDay = null;
        }
      }
      
      // Procesar compatibilidad
      _compatibility = response['compatibility']?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('[ERROR] Error al procesar respuesta directa: $e');
    }
  }
}
