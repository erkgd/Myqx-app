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
      notifyListeners();      final response = await _apiClient.post('/ratings/submit', body: {
        'content_id': albumId,
        'content_type': 'album',  // Identificador explícito de tipo
        'rating': rating,
        'user_id': userId,  // Include user ID in the request
        'timestamp': DateTime.now().toIso8601String(), // Añadir timestamp para auditoría
      });
      
      debugPrint('[RATING][ALBUM] Rating sent to server: $albumId - $rating by user $userId');
      debugPrint('[RATING][ALBUM] Server response: ${response.toString()}');
      
      // Incluso si el servidor devuelve un error, mantenemos la calificación en caché
      // para mejorar la experiencia de usuario
      
      return response['success'] ?? false;    } catch (e) {
      _errorMessage = 'Error rating album: ${e.toString()}';
      debugPrint('[ERROR][ALBUM] $_errorMessage');
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
      notifyListeners();      final response = await _apiClient.post('/ratings/submit', body: {
        'content_id': songId,
        'content_type': 'track',  // Identificador explícito de tipo
        'rating': rating,
        'user_id': userId,  // Include user ID in the request
        'timestamp': DateTime.now().toIso8601String(), // Añadir timestamp para auditoría
      });
      
      debugPrint('[RATING][TRACK] Rating sent to server: $songId - $rating by user $userId');
      debugPrint('[RATING][TRACK] Server response: ${response.toString()}');
      
      // Incluso si el servidor devuelve un error, mantenemos la calificación en caché
      // para mejorar la experiencia de usuario
      
      return response['success'] ?? false;    } catch (e) {
      _errorMessage = 'Error rating track: ${e.toString()}';
      debugPrint('[ERROR][TRACK] $_errorMessage');
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
        debugPrint('[RATING][ALBUM] Fetching rating from server: $albumId');
      // Usar el endpoint unificado con parámetros de tipo de contenido
      final response = await _apiClient.get('/ratings/get?content_id=$albumId&content_type=album&user_id=$userId');
      final rating = response['rating']?.toDouble();
      
      // Si se obtuvo una calificación, guardarla en caché
      if (rating != null) {
        RatingCache().setAlbumRating(albumId, rating);
      } else {
        // También cacheamos los resultados nulos para evitar peticiones repetidas
        RatingCache().setAlbumRating(albumId, null);
      }
      
      return rating;    } catch (e) {
      debugPrint('[ERROR][ALBUM] Error getting rating: ${e.toString()}');
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
        debugPrint('[RATING][TRACK] Fetching rating from server: $songId');
      // Usar el endpoint unificado con parámetros de tipo de contenido
      final response = await _apiClient.get('/ratings/get?content_id=$songId&content_type=track&user_id=$userId');
      final rating = response['rating']?.toDouble();
      
      // Si se obtuvo una calificación, guardarla en caché
      if (rating != null) {
        RatingCache().setTrackRating(songId, rating);
      } else {
        // También cacheamos los resultados nulos para evitar peticiones repetidas
        RatingCache().setTrackRating(songId, null);
      }
      
      return rating;    } catch (e) {
      debugPrint('[ERROR][TRACK] Error getting rating: ${e.toString()}');
      // Guardamos el error en caché para evitar peticiones repetidas que sabemos que van a fallar
      RatingCache().setTrackRating(songId, null);
      return null;
    }
  }
  /// Limpia la caché de calificaciones
  void clearRatingsCache() {
    RatingCache().clear();
    debugPrint('[RATING][CACHE] All ratings cache cleared');
  }
  
  
}
