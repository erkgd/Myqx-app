// Importaciones requeridas
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/services/spotify_album_service.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/feed_item.dart';

/// Servicio para gestionar el feed de contenido calificado
class BroadcastService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  
  String? _errorMessage;
  bool _isLoading = false;
  List<FeedItem> _feedItems = [];
  
  // Getters
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<FeedItem> get feedItems => _feedItems;
  
  // Constructor
  BroadcastService({ApiClient? apiClient, SecureStorage? secureStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorage();
  
  /// Cambia el estado de carga sin notificar inmediatamente
  void _setLoading(bool loading) {
    _isLoading = loading;
  }
  
  /// Actualiza el estado de error sin notificar inmediatamente
  void _setError(String? error) {
    _errorMessage = error;
  }
  
  /// Notifica los cambios de manera segura usando microtask
  void _safeNotify() {
    Future.microtask(() {
      notifyListeners();
    });
  }
    /// Obtiene el feed de calificaciones recientes
  /// 
  /// [limit] - número máximo de ítems a obtener
  /// [offset] - índice desde el cual cargar (para paginación)
  /// [userId] - ID del usuario (ahora requerido por el backend)
  Future<List<FeedItem>> getFeed({int limit = 20, int offset = 0, String userId = '3'}) async {
    _setLoading(true);
    _setError(null); // Limpiar errores anteriores
    
    try {
      // Ahora incluimos el user_id como parámetro requerido
      final endpoint = '/feed?limit=$limit&offset=$offset&user_id=$userId';
      final response = await _apiClient.get(endpoint);
      
      // Debug de la respuesta completa
      debugPrint('[FEED] Respuesta obtenida: ${response.keys.join(', ')}');
      
      late List<dynamic> feedData;
      
      // Compatibilidad con dos estructuras de respuesta
      if (response['items'] != null) {
        feedData = response['items'];
      } else if (response['data'] != null) {
        feedData = response['data'];
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
      
      if (feedData.isNotEmpty) {
        debugPrint('[FEED] Procesando ${feedData.length} elementos');
        
        // Procesar elementos usando un método dedicado
        _feedItems = await _processRawFeedItems(feedData);
        return _feedItems;
      } else {
        _setError('No se encontraron elementos en el feed');
        debugPrint('[FEED][WARNING] $_errorMessage');
        return [];
      }
    } catch (e) {
      _setError('Error al cargar el feed: ${e.toString()}');
      debugPrint('[FEED][ERROR] $_errorMessage');
      return [];
    } finally {
      _setLoading(false);
      // Notificar los cambios de estado de manera segura
      _safeNotify();
    }
  }
  
  /// Método privado para obtener detalles de una canción directamente de la API de Spotify
  Future<Map<String, dynamic>?> _getTrackDetailsDirectly(String trackId) async {
    try {
      // Obtener token de autenticación usando SpotifyAuthService
      final authService = SpotifyAuthService();
      final token = await authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[TRACK][ERROR] No se pudo obtener el token de autenticación');
        return null;
      }
      
      // Realizar petición directa al endpoint de tracks
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('[TRACK][SUCCESS] Datos obtenidos para track: ${data['name']}');
        return data;
      } else {
        debugPrint('[TRACK][ERROR] Error al obtener datos. Código: ${response.statusCode}');
        debugPrint('[TRACK][ERROR] Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[TRACK][ERROR] Excepción al obtener detalles de la track: $e');
      return null;
    }
  }
  
  /// Procesa los elementos crudos del feed y obtiene información adicional si es necesario
  Future<List<FeedItem>> _processRawFeedItems(List<dynamic> rawItems) async {
    List<FeedItem> processedItems = [];
    final albumService = SpotifyAlbumService();
    
    for (var item in rawItems) {
      try {        
        // Si los campos esenciales están nulos, debemos obtenerlos
        String? title = item['title'];
        String? artist = item['artist'];
        String? imageUrl = item['imageUrl'];
        final String contentId = item['contentId'] ?? '';
        final String contentType = item['contentType'] ?? 'album';
        // El spotifyId puede ser útil como alternativa si el contentId está vacío
        final String spotifyId = item['spotifyId'] ?? '';
        final String idToUse = contentId.isNotEmpty ? contentId : spotifyId.replaceAll('spotify:album:', '').replaceAll('spotify:track:', '');
          
        // IMPORTANTE: Ya no usamos el método fromJson directamente
        // porque necesitamos procesar manualmente todos los elementos
        // para asegurarnos de que la review se maneje correctamente
        
        // Debug para inspeccionar todos los campos del elemento
        debugPrint('[FEED_PROCESS] Procesando elemento con ID: ${item['id']}');
        debugPrint('[FEED_PROCESS] Campos disponibles: ${item.keys.join(', ')}');
        debugPrint('[FEED_PROCESS] Tipo: $contentType, ContentID: $contentId, SpotifyID: $spotifyId');
        
        // Si hay review, mostrarlo específicamente
        if (item['review'] != null && item['review'].toString() != "null" && item['review'].toString().isNotEmpty) {
          debugPrint('[FEED_PROCESS] ✅ Review encontrada en datos originales: "${item['review']}"');
        }
          
        // Si no, recuperar los datos faltantes desde la API de Spotify
        if (idToUse.isNotEmpty && (title == null || artist == null || imageUrl == null)) {
          // Si es un álbum
          if (contentType == 'album') {
            try {
              final albumDetails = await albumService.getAlbumDetails(idToUse);
              
              // Actualizar los datos faltantes
              title = albumDetails.name;
              artist = albumDetails.artistName;
              imageUrl = albumDetails.coverUrl;
              
              debugPrint('[FEED] ✅ Completados datos de álbum: $title por $artist');
            } catch (e) {
              debugPrint('[FEED][ERROR] Error al obtener datos del álbum $contentId: $e');
            }
          }          
          // Si es una canción, usamos un método especializado de la API de Spotify
          else if (contentType == 'track') {
            try {
              // Log para depuración
              debugPrint('[FEED][DEBUG] Intentando obtener información para track con ID: $idToUse');
              
              // Usar directamente el endpoint de tracks de Spotify en lugar de search
              // Esto es mucho más preciso para obtener datos de una track específica
              final trackDetails = await _getTrackDetailsDirectly(idToUse);
              
              if (trackDetails != null) {
                // Actualizar los datos faltantes con datos reales del track
                title = trackDetails['name'];
                
                // Obtener el nombre del artista de forma segura
                if (trackDetails['artists'] != null && 
                    trackDetails['artists'] is List && 
                    (trackDetails['artists'] as List).isNotEmpty) {
                  artist = trackDetails['artists'][0]['name'];
                }
                
                // Obtener la URL de la imagen de forma segura
                if (trackDetails['album'] != null && 
                    trackDetails['album']['images'] != null && 
                    trackDetails['album']['images'] is List && 
                    (trackDetails['album']['images'] as List).isNotEmpty) {
                  imageUrl = trackDetails['album']['images'][0]['url'];
                }
                
                debugPrint('[FEED] ✅ Completados datos de canción con API directa: $title por $artist');
                debugPrint('[FEED] ✅ URL de imagen: $imageUrl');
              } else {
                debugPrint('[FEED][WARN] ⚠️ No se pudo obtener información para el track con ID: $idToUse');
                // No agregamos valores por defecto, esto permitirá filtrar items incompletos
              }
            } catch (e) {
              debugPrint('[FEED][ERROR] ❌ Error al obtener datos de la canción $contentId: $e');
              // No agregamos valores por defecto
            }
          }
        }
        
        // Verificar si el comentario existe en el objeto (inspeccionar todos los campos posibles)
        debugPrint('[FEED][DEBUG] Inspección de campos del item: ${item.keys.join(', ')}');
        // ANÁLISIS DETALLADO DEL REVIEW/COMMENT - Manejo mejorado para la estructura del API
        String? reviewText;
        
        // Extraer el campo comment primero (estructura actual del API)
        if (item.containsKey('comment')) {
          var rawComment = item['comment'];
          debugPrint('[FEED_PROCESS] ⚙️ Campo comment encontrado - Valor: "$rawComment", Tipo: ${rawComment?.runtimeType}');
          
          // Verificar que el comment no sea "null" como string o un valor null real o vacío
          if (rawComment != null && 
              rawComment.toString() != "null" && 
              rawComment.toString().isNotEmpty) {
            reviewText = rawComment.toString();
            debugPrint('[FEED] ✅ Comment extraído correctamente: "$reviewText"');
          } else {
            debugPrint('[FEED_PROCESS] Comment inválido: ${rawComment?.toString() ?? "null"}');
          }
        }
        
        // Si comment no tiene valor, probar con review (para compatibilidad)
        if (reviewText == null && item.containsKey('review')) {
          var rawReview = item['review'];
          debugPrint('[FEED_PROCESS] ⚙️ Campo review encontrado - Valor: "$rawReview", Tipo: ${rawReview?.runtimeType}');
          
          // Verificar que el review no sea "null" como string o un valor null real o vacío
          if (rawReview != null && 
              rawReview.toString() != "null" && 
              rawReview.toString().isNotEmpty) {
            reviewText = rawReview.toString();
            debugPrint('[FEED] ✅ Review extraído correctamente: "$reviewText"');
          } else {
            debugPrint('[FEED_PROCESS] Review inválido: ${rawReview?.toString() ?? "null"}');
          }
        }
        
        // Imprimir para depuración lo que se encontró
        if (reviewText != null && reviewText.isNotEmpty) {
          debugPrint('[FEED] ✅ Comentario encontrado para item $contentId: "$reviewText"');
          // Inspeccionar el tipo del review para depuración
          debugPrint('[FEED] Tipo del comentario: ${reviewText.runtimeType} - Longitud: ${reviewText.length}');
        } else {
          // Inspección detallada de los valores recibidos
          final rawReview = item['review'];
          debugPrint('[FEED] ⚠️ NO se encontró comentario final para item $contentId');
          debugPrint('[FEED] ⚙️ Valor raw de review=${rawReview}, Tipo=${rawReview?.runtimeType}');
          if (rawReview != null) {
            debugPrint('[FEED] ⚙️ review.toString()="${rawReview.toString()}", Vacío=${rawReview.toString().isEmpty}, Igual a "null"=${rawReview.toString() == "null"}');
          }
        }
        
        // FILTRO: Solo agregar al feed si tenemos los campos requeridos
        // Esto evita que se muestren tracks que no tenemos o con datos incompletos
        if (title != null && artist != null && imageUrl != null) {
          final processedItem = FeedItem(
            id: item['id'] ?? '',
            contentId: contentId,
            contentType: contentType,
            title: title,
            artist: artist,
            imageUrl: imageUrl,
            rating: (item['rating'] as num?)?.toDouble() ?? 0.0,
            normalizedRating: (item['normalizedRating'] as num?)?.toDouble() ?? (item['rating'] as num?)?.toDouble() ?? 0.0,
            review: reviewText, // Usar la variable que puede venir de 'review' o 'comment'
            userId: item['userId'] ?? '',
            username: item['username'] ?? '',
            userImageUrl: item['userImage'] ?? item['profileImage'] ?? '',
            timestamp: item['date'] != null 
              ? DateTime.parse(item['date']) 
              : DateTime.now(),
          );
          
          // Debug final para ver si el review se asignó correctamente
          if (processedItem.review != null && processedItem.review!.isNotEmpty) {
            debugPrint('[FEED_ITEM_FINAL] ✅ Item procesado con review: "${processedItem.review}" para $contentId');
          } else {
            debugPrint('[FEED_ITEM_FINAL] ⚠️ Item procesado SIN review para $contentId');
          }
          
          processedItems.add(processedItem);
        } else {
          debugPrint('[FEED_FILTER] ⛔ Elemento filtrado por datos incompletos. ID: ${item['id']}, Tipo: $contentType');
          debugPrint('[FEED_FILTER] ⛔ Datos faltantes: title=${title == null}, artist=${artist == null}, imageUrl=${imageUrl == null}');
        }
      } catch (e) {
        debugPrint('[FEED][ERROR] Error al procesar elemento del feed: $e');
      }
    }
    
    debugPrint('[FEED] Total elementos procesados: ${processedItems.length}/${rawItems.length}');
    return processedItems;
  }
  
  /// Obtiene el feed de calificaciones de un usuario específico
  /// 
  /// [userId] - ID del usuario del cual se quiere obtener el feed
  /// [limit] - número máximo de ítems a obtener
  /// [offset] - índice desde el cual cargar (para paginación)
  Future<List<FeedItem>> getUserFeed(String userId, {int limit = 20, int offset = 0}) async {
    _setLoading(true);
    _setError(null); // Limpiar errores anteriores
    
    try {
      final endpoint = '/user/$userId/feed?limit=$limit&offset=$offset';
      final response = await _apiClient.get(endpoint);
      
      late List<dynamic> feedData;
      
      // Compatibilidad con dos estructuras de respuesta
      if (response['items'] != null) {
        feedData = response['items'];
      } else if (response['data'] != null) {
        feedData = response['data'];
      } else {
        throw Exception('Formato de respuesta no reconocido');
      }
      
      if (feedData != null && feedData.isNotEmpty) {
        final userFeed = await _processRawFeedItems(feedData);
        return userFeed;
      } else {
        _setError('No se encontraron elementos en el feed del usuario');
        debugPrint('[FEED][WARNING] $_errorMessage');
        return [];
      }
    } catch (e) {
      _setError('Error al cargar el feed del usuario: ${e.toString()}');
      debugPrint('[FEED][ERROR] $_errorMessage');
      return [];
    } finally {
      _setLoading(false);
      // Notificar los cambios de estado de manera segura
      _safeNotify();
    }
  }
    /// Actualiza el feed obteniendo datos nuevos desde el servidor
  Future<void> refreshFeed({String userId = '3'}) async {
    await getFeed(userId: userId);
  }
}
