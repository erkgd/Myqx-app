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
  /// [comment] es un comentario opcional del usuario sobre el álbum
  Future<bool> rateAlbum(String albumId, double rating, {String? comment}) async {
    if (albumId.isEmpty) {
      debugPrint('[ERROR] Empty album ID');
      return false;
    }
    
    // Debug para verificar que el comentario llegue correctamente
    debugPrint('[DEBUG][SEARCH_SERVICE] rateAlbum called with comment: "${comment ?? "NO COMMENT"}"');

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

      // Construir el cuerpo de la petición
      final requestBody = {
        'content_id': albumId,
        'content_type': 'album',  // Identificador explícito de tipo
        'rating': rating,
        'user_id': userId,  // Include user ID in the request
        'timestamp': DateTime.now().toIso8601String(), // Añadir timestamp para auditoría
      };
      
      // Añadir el campo comment solo si hay un comentario (no estamos enviando nulls)
      if (comment != null && comment.isNotEmpty) {
        // Nota: El backend espera un campo "comment" pero luego lo devuelve como "comment"
        requestBody['comment'] = comment;
        // Log para depuración
        debugPrint('[DEBUG][SEARCH_SERVICE] Adding comment to request: "$comment"');
      } else {
        debugPrint('[DEBUG][SEARCH_SERVICE] No comment added to request');
      }
      
      // Realizar la petición al API
      final response = await _apiClient.post('/ratings/submit', body: requestBody);
      
      // Log para depurar la respuesta completa
      debugPrint('[RATING_SERVICE] Respuesta completa del servidor: ${response.toString()}');
      
      debugPrint('[RATING][ALBUM] Rating sent to server: $albumId - $rating by user $userId${comment != null ? ' with comment: "$comment"' : ' without comment'}');
      debugPrint('[RATING][ALBUM] Server response: ${response.toString()}');
      
      // Incluso si el servidor devuelve un error, mantenemos la calificación en caché
      // para mejorar la experiencia de usuario
      
      return response['success'] ?? false;
    } catch (e) {
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
  /// [trackId] es el ID de la canción en Spotify
  /// [rating] es la calificación dada por el usuario (0-5)
  /// [comment] es un comentario opcional del usuario sobre la canción
  Future<bool> rateTrack(String trackId, double rating, {String? comment}) async {
    if (trackId.isEmpty) {
      debugPrint('[ERROR] Empty track ID');
      return false;
    }

    try {
      // IMPORTANTE: Guardar en caché primero, antes de intentar enviar al servidor
      RatingCache().setTrackRating(trackId, rating);
      debugPrint('[CACHE] Track rating cached immediately: $trackId - $rating');
      
      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('[ERROR] User ID not available');
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Construir el cuerpo de la petición
      final requestBody = {
        'content_id': trackId,
        'content_type': 'track', // Identificador explícito de tipo
        'rating': rating,
        'user_id': userId, // Include user ID in the request
        'timestamp': DateTime.now().toIso8601String(), // Añadir timestamp para auditoría
      };
      
      // Añadir el campo comment solo si hay un comentario
      if (comment != null && comment.isNotEmpty) {
        requestBody['comment'] = comment;
        debugPrint('[DEBUG][SEARCH_SERVICE] Adding comment to track request: "$comment"');
      }

      // Realizar la petición al API
      final response = await _apiClient.post('/ratings/submit', body: requestBody);
      
      // Log para depurar la respuesta completa
      debugPrint('[RATING_SERVICE] Respuesta completa del servidor: ${response.toString()}');
      
      debugPrint('[RATING][TRACK] Rating sent to server: $trackId - $rating by user $userId${comment != null ? ' with comment: "$comment"' : ' without comment'}');
      debugPrint('[RATING][TRACK] Server response: ${response.toString()}');

      return response['success'] ?? false;
    } catch (e) {
      _errorMessage = 'Error rating track: ${e.toString()}';
      debugPrint('[ERROR][TRACK] $_errorMessage');
      // La calificación ya se guardó en caché
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Obtiene la calificación de un álbum
  /// 
  /// [albumId] es el ID del álbum en Spotify
  double? getAlbumRating(String albumId) {
    return RatingCache().getAlbumRating(albumId);
  }
  /// Obtiene la calificación de una canción
  /// 
  /// [trackId] es el ID de la canción en Spotify
  double? getTrackRating(String trackId) {
    return RatingCache().getTrackRating(trackId);
  }
  
  /// Obtiene la calificación de una canción (alias para getTrackRating)
  /// 
  /// [songId] es el ID de la canción en Spotify
  double? getSongRating(String songId) {
    return getTrackRating(songId); // Alias para mantener compatibilidad
  }
  
  /// Califica una canción (alias para rateTrack)
  /// 
  /// [songId] es el ID de la canción en Spotify
  /// [rating] es la calificación dada por el usuario (0-5)
  /// [comment] es un comentario opcional del usuario sobre la canción
  Future<bool> rateSong(String songId, double rating, {String? comment}) async {
    return rateTrack(songId, rating, comment: comment); // Alias para mantener compatibilidad
  }
  
  /// Limpia la caché de calificaciones
  void clearRatingsCache() {
    debugPrint('[CACHE] Clearing all ratings cache');
    RatingCache().clearAll();
  }
}
