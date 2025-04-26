import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/utils/rating_cache.dart';

/// Servicio que gestiona las operaciones relacionadas con búsquedas y calificaciones
class SearchService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Constructor with explicit initialization
  SearchService({ApiClient? apiClient, SecureStorage? secureStorage}) 
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorage();
  /// Califica un álbum
  /// 
  /// [albumId] es el ID del álbum en Spotify
  /// [rating] es la calificación dada por el usuario (0-5)
  Future<bool> rateAlbum(String albumId, double rating) async {
    if (albumId.isEmpty) {
      debugPrint('[ERROR] Empty album ID');
      return false;
    }

    try {
      // IMPORTANTE: Siempre guardar en caché primero, incluso antes de intentar enviar al servidor
      // Esto garantiza que la calificación persista localmente incluso si falla la petición
      RatingCache().setAlbumRating(albumId, rating);
      debugPrint('[CACHE] Album rating cached immediately: $albumId - $rating');
      
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available');
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.post('/albums/rate', body: {
        'album_id': albumId,
        'rating': rating,
        'user_id': userId,  // Include user ID in the request
      });
      
      debugPrint('[DEBUG] Album rating sent to server: $albumId - $rating by user $userId');
      debugPrint('[DEBUG] Server response: ${response.toString()}');
      
      // Incluso si el servidor devuelve un error, mantenemos la calificación en caché
      // para mejorar la experiencia de usuario
      
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error rating album: ${e.toString()}';
      debugPrint('[ERROR] $_errorMessage');
      // La calificación ya se guardó en caché, así que el error del servidor no afecta la experiencia de usuario
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  /// Califica una canción
  /// 
  /// [songId] es el ID de la canción en Spotify
  /// [rating] es la calificación dada por el usuario (0-5)
  Future<bool> rateSong(String songId, double rating) async {
    if (songId.isEmpty) {
      debugPrint('[ERROR] Empty song ID');
      return false;
    }
    
    try {
      // IMPORTANTE: Siempre guardar en caché primero, incluso antes de intentar enviar al servidor
      // Esto garantiza que la calificación persista localmente incluso si falla la petición
      RatingCache().setTrackRating(songId, rating);
      debugPrint('[CACHE] Track rating cached immediately: $songId - $rating');
      
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available');
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiClient.post('/tracks/rate', body: {
        'track_id': songId,
        'rating': rating,
        'user_id': userId,  // Include user ID in the request
      });
      
      debugPrint('[DEBUG] Track rating sent to server: $songId - $rating by user $userId');
      debugPrint('[DEBUG] Server response: ${response.toString()}');
      
      // Incluso si el servidor devuelve un error, mantenemos la calificación en caché
      // para mejorar la experiencia de usuario
      
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error rating track: ${e.toString()}';
      debugPrint('[ERROR] $_errorMessage');
      // La calificación ya se guardó en caché, así que el error del servidor no afecta la experiencia de usuario
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Recupera la calificación actual de un álbum si existe
  Future<double?> getAlbumRating(String albumId) async {
    if (albumId.isEmpty) return null;
    
    // Verificar primero en la caché global
    if (RatingCache().hasValidAlbumRating(albumId)) {
      final cachedRating = RatingCache().getAlbumRating(albumId);
      debugPrint('[CACHE] Using cached album rating: $albumId - $cachedRating');
      return cachedRating;
    }
    
    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available for getting album rating');
        return null;
      }
      
      debugPrint('[DEBUG] Fetching album rating from server: $albumId');
      // Include user_id as a query parameter
      final response = await _apiClient.get('/albums/$albumId/rating?user_id=$userId');
      final rating = response['rating']?.toDouble();
      
      // Si se obtuvo una calificación, guardarla en caché
      if (rating != null) {
        RatingCache().setAlbumRating(albumId, rating);
      } else {
        // También cacheamos los resultados nulos para evitar peticiones repetidas
        RatingCache().setAlbumRating(albumId, null);
      }
      
      return rating;
    } catch (e) {
      debugPrint('[ERROR] Error getting album rating: ${e.toString()}');
      // Guardamos el error en caché para evitar peticiones repetidas que sabemos que van a fallar
      RatingCache().setAlbumRating(albumId, null);
      return null;
    }
  }

  /// Recupera la calificación actual de una canción si existe
  Future<double?> getSongRating(String songId) async {
    if (songId.isEmpty) return null;
    
    // Verificar primero en la caché global
    if (RatingCache().hasValidTrackRating(songId)) {
      final cachedRating = RatingCache().getTrackRating(songId);
      debugPrint('[CACHE] Using cached track rating: $songId - $cachedRating');
      return cachedRating;
    }
    
    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available for getting track rating');
        return null;
      }
      
      debugPrint('[DEBUG] Fetching track rating from server: $songId');
      // Include user_id as a query parameter
      final response = await _apiClient.get('/tracks/$songId/rating?user_id=$userId');
      final rating = response['rating']?.toDouble();
      
      // Si se obtuvo una calificación, guardarla en caché
      if (rating != null) {
        RatingCache().setTrackRating(songId, rating);
      } else {
        // También cacheamos los resultados nulos para evitar peticiones repetidas
        RatingCache().setTrackRating(songId, null);
      }
      
      return rating;
    } catch (e) {
      debugPrint('[ERROR] Error getting track rating: ${e.toString()}');
      // Guardamos el error en caché para evitar peticiones repetidas que sabemos que van a fallar
      RatingCache().setTrackRating(songId, null);
      return null;
    }
  }

  /// Limpia la caché de calificaciones
  void clearRatingsCache() {
    RatingCache().clear();
    debugPrint('[DEBUG] Ratings cache cleared');
  }
}
