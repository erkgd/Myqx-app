import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';

/// Clase para almacenar calificaciones en caché con tiempo de expiración
class _CachedRating {
  final double rating;
  final DateTime timestamp;
  
  _CachedRating(this.rating) : timestamp = DateTime.now();
  
  bool isExpired(Duration cacheDuration) {
    return DateTime.now().difference(timestamp) > cacheDuration;
  }
}

/// Servicio que gestiona las operaciones relacionadas con búsquedas y calificaciones
class SearchService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  String? _errorMessage;
  bool _isLoading = false;

  // Sistema de caché para calificaciones
  final Map<String, _CachedRating> _albumRatingsCache = HashMap<String, _CachedRating>();
  final Map<String, _CachedRating> _songRatingsCache = HashMap<String, _CachedRating>();
  
  // Tiempo de expiración de la caché (10 minutos)
  final Duration _cacheDuration = const Duration(minutes: 10);

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
      
      debugPrint('[DEBUG] Album rating sent: $albumId - $rating by user $userId');
      
      // Si la calificación fue exitosa, actualizar la caché
      if (response['success'] == true) {
        _albumRatingsCache[albumId] = _CachedRating(rating);
        debugPrint('[DEBUG] Album rating cached: $albumId - $rating');
      }
      
      debugPrint('[DEBUG] Response: ${response.toString()}');
      
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error rating album: ${e.toString()}';
      debugPrint('[ERROR] $_errorMessage');
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
      
      debugPrint('[DEBUG] Track rating sent: $songId - $rating by user $userId');
      
      // Si la calificación fue exitosa, actualizar la caché
      if (response['success'] == true) {
        _songRatingsCache[songId] = _CachedRating(rating);
        debugPrint('[DEBUG] Song rating cached: $songId - $rating');
      }
      
      debugPrint('[DEBUG] Response: ${response.toString()}');
      
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error rating track: ${e.toString()}';
      debugPrint('[ERROR] $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Recupera la calificación actual de un álbum si existe
  Future<double?> getAlbumRating(String albumId) async {
    if (albumId.isEmpty) return null;
    
    // Verificar si existe en caché y no ha expirado
    final cachedRating = _albumRatingsCache[albumId];
    if (cachedRating != null && !cachedRating.isExpired(_cacheDuration)) {
      debugPrint('[DEBUG] Using cached album rating: $albumId - ${cachedRating.rating}');
      return cachedRating.rating;
    }
    
    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available for getting album rating');
        return null;
      }
      
      // Include user_id as a query parameter
      final response = await _apiClient.get('/albums/$albumId/rating?user_id=$userId');
      final rating = response['rating']?.toDouble();
      
      // Si se obtuvo una calificación, guardarla en caché
      if (rating != null) {
        _albumRatingsCache[albumId] = _CachedRating(rating);
        debugPrint('[DEBUG] Album rating cached from server: $albumId - $rating');
      }
      
      return rating;
    } catch (e) {
      debugPrint('[ERROR] Error getting album rating: ${e.toString()}');
      return null;
    }
  }

  /// Recupera la calificación actual de una canción si existe
  Future<double?> getSongRating(String songId) async {
    if (songId.isEmpty) return null;
    
    // Verificar si existe en caché y no ha expirado
    final cachedRating = _songRatingsCache[songId];
    if (cachedRating != null && !cachedRating.isExpired(_cacheDuration)) {
      debugPrint('[DEBUG] Using cached song rating: $songId - ${cachedRating.rating}');
      return cachedRating.rating;
    }
    
    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available for getting track rating');
        return null;
      }
      
      // Include user_id as a query parameter
      final response = await _apiClient.get('/tracks/$songId/rating?user_id=$userId');
      final rating = response['rating']?.toDouble();
      
      // Si se obtuvo una calificación, guardarla en caché
      if (rating != null) {
        _songRatingsCache[songId] = _CachedRating(rating);
        debugPrint('[DEBUG] Song rating cached from server: $songId - $rating');
      }
      
      return rating;
    } catch (e) {
      debugPrint('[ERROR] Error getting track rating: ${e.toString()}');
      return null;
    }
  }

  /// Limpia la caché de calificaciones
  void clearRatingsCache() {
    _albumRatingsCache.clear();
    _songRatingsCache.clear();
    debugPrint('[DEBUG] Ratings cache cleared');
  }
}
