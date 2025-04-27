import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/utils/rating_cache.dart';

/// Servicio dedicado a la gestión de calificaciones tanto de álbumes como de canciones
class RatingService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Constructor with explicit initialization
  RatingService({ApiClient? apiClient, SecureStorage? secureStorage}) 
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorage();

  /// Califica un contenido (álbum o canción)
  /// 
  /// [contentId] es el ID del contenido en Spotify
  /// [contentType] es el tipo de contenido ('album' o 'track')
  /// [rating] es la calificación dada por el usuario (0-5)
  Future<bool> rateContent(String contentId, String contentType, double rating) async {
    if (contentId.isEmpty) {
      debugPrint('[ERROR][RATING] Empty content ID');
      return false;
    }

    if (contentType != 'album' && contentType != 'track') {
      debugPrint('[ERROR][RATING] Invalid content type: $contentType');
      return false;
    }

    try {
      // IMPORTANTE: Siempre guardar en caché primero, incluso antes de intentar enviar al servidor
      // Esto garantiza que la calificación persista localmente incluso si falla la petición
      if (contentType == 'album') {
        RatingCache().setAlbumRating(contentId, rating);
      } else {
        RatingCache().setTrackRating(contentId, rating);
      }
      debugPrint('[CACHE][RATING] $contentType rating cached: $contentId - $rating');
      
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR][RATING] User ID not available');
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Usar el método especializado para calificaciones
      final response = await _apiClient.submitRating(
        contentId: contentId,
        contentType: contentType,
        rating: rating,
        userId: userId,
      );
      
      debugPrint('[RATING] $contentType rating processed: $contentId - $rating by user $userId');
      
      // Incluso si el servidor devuelve un error, mantenemos la calificación en caché
      // para mejorar la experiencia de usuario
      
      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error rating $contentType: ${e.toString()}';
      debugPrint('[ERROR][RATING] $_errorMessage');
      // La calificación ya se guardó en caché, así que el error del servidor no afecta la experiencia de usuario
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método conveniente para calificar un álbum
  Future<bool> rateAlbum(String albumId, double rating) {
    return rateContent(albumId, 'album', rating);
  }

  /// Método conveniente para calificar una canción
  Future<bool> rateTrack(String trackId, double rating) {
    return rateContent(trackId, 'track', rating);
  }
  
  /// Recupera la calificación de un contenido (álbum o canción)
  Future<double?> getContentRating(String contentId, String contentType) async {
    if (contentId.isEmpty) return null;
    
    if (contentType != 'album' && contentType != 'track') {
      debugPrint('[ERROR][RATING] Invalid content type: $contentType');
      return null;
    }
    
    // Verificar primero en la caché global
    bool hasValidCache = false;
    double? cachedRating;
    
    if (contentType == 'album') {
      hasValidCache = RatingCache().hasValidAlbumRating(contentId);
      if (hasValidCache) {
        cachedRating = RatingCache().getAlbumRating(contentId);
      }
    } else {
      hasValidCache = RatingCache().hasValidTrackRating(contentId);
      if (hasValidCache) {
        cachedRating = RatingCache().getTrackRating(contentId);
      }
    }
    
    if (hasValidCache) {
      debugPrint('[CACHE][RATING] Using cached $contentType rating: $contentId - $cachedRating');
      return cachedRating;
    }
    
    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR][RATING] User ID not available for getting rating');
        return null;
      }
      
      // Usar el método especializado para obtener calificaciones
      final rating = await _apiClient.getRating(
        contentId: contentId,
        contentType: contentType,
        userId: userId,
      );
      
      // Si se obtuvo una calificación, guardarla en caché
      if (contentType == 'album') {
        RatingCache().setAlbumRating(contentId, rating);
      } else {
        RatingCache().setTrackRating(contentId, rating);
      }
      
      return rating;
    } catch (e) {
      debugPrint('[ERROR][RATING] Error getting $contentType rating: ${e.toString()}');
      // Guardamos el error en caché para evitar peticiones repetidas que sabemos que van a fallar
      if (contentType == 'album') {
        RatingCache().setAlbumRating(contentId, null);
      } else {
        RatingCache().setTrackRating(contentId, null);
      }
      return null;
    }
  }

  /// Método conveniente para obtener la calificación de un álbum
  Future<double?> getAlbumRating(String albumId) {
    return getContentRating(albumId, 'album');
  }

  /// Método conveniente para obtener la calificación de una canción
  Future<double?> getTrackRating(String trackId) {
    return getContentRating(trackId, 'track');
  }
  
  /// Elimina una calificación del servidor y de la caché local
  Future<bool> deleteContentRating(String contentId, String contentType) async {
    if (contentId.isEmpty) {
      debugPrint('[ERROR][RATING] Empty content ID for deletion');
      return false;
    }

    if (contentType != 'album' && contentType != 'track') {
      debugPrint('[ERROR][RATING] Invalid content type: $contentType');
      return false;
    }

    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR][RATING] User ID not available for deletion');
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Usar el método especializado para eliminar calificaciones
      final success = await _apiClient.deleteRating(
        contentId: contentId,
        contentType: contentType,
        userId: userId,
      );
      
      // También eliminar de la caché local independientemente del resultado del servidor
      if (contentType == 'album') {
        RatingCache().setAlbumRating(contentId, null);
      } else {
        RatingCache().setTrackRating(contentId, null);
      }
      
      debugPrint('[RATING][DELETE] Rating deletion for $contentType: $contentId (success: $success)');
      return success;
    } catch (e) {
      _errorMessage = 'Error deleting $contentType rating: ${e.toString()}';
      debugPrint('[ERROR][RATING] $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método conveniente para eliminar la calificación de un álbum
  Future<bool> deleteAlbumRating(String albumId) {
    return deleteContentRating(albumId, 'album');
  }

  /// Método conveniente para eliminar la calificación de una canción
  Future<bool> deleteTrackRating(String trackId) {
    return deleteContentRating(trackId, 'track');
  }
  
  /// Limpia toda la caché de calificaciones
  void clearRatingsCache() {
    RatingCache().clear();
    debugPrint('[RATING][CACHE] All ratings cache cleared');
  }
}
