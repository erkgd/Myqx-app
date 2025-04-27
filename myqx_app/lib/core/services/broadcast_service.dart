import 'dart:math' as Math;
import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/services/spotify_album_service.dart';
import 'package:myqx_app/core/services/spotify_search_service.dart';
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
    // Usar microtask para asegurar que la notificación suceda fuera del ciclo de construcción
    Future.microtask(() => notifyListeners());
  }
  
  /// Obtiene el feed de calificaciones recientes
  /// 
  /// [limit] - número máximo de ítems a obtener
  /// [offset] - índice desde el cual cargar (para paginación)
  Future<List<FeedItem>> getFeed({int limit = 20, int offset = 0}) async {
    try {
      // Actualizamos el estado sin notificar inmediatamente
      _setLoading(true);
      _setError(null);
      
      // Obtener el ID del usuario
      final userId = await _secureStorage.getUserId();
        // Realizar solicitud al BFF
      final response = await _apiClient.get(
        '/feed?limit=$limit&offset=$offset${userId != null ? '&user_id=$userId' : ''}'
      );
      
      debugPrint('[FEED] Respuesta del servidor: ${response.toString().substring(0, 500)}...(truncado)');
      
      // Procesar respuesta - Verificar las dos posibles estructuras: 'items' o 'data'
      List<dynamic>? feedData;
      if (response['items'] != null) {
        feedData = response['items'];
      } else if (response['data'] != null) {
        feedData = response['data'];
      }
      
      if (feedData != null && feedData.isNotEmpty) {
        // Generar elementos del feed y obtener datos adicionales si es necesario
        final items = await _processRawFeedItems(feedData);
        _feedItems = items;
        
        debugPrint('[FEED] Obtenidos ${_feedItems.length} elementos del feed');
        return _feedItems;
      } else {
        _setError('No se encontraron elementos en el feed');
        debugPrint('[FEED][ERROR] $_errorMessage');
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
  
  /// Procesa los elementos crudos del feed y obtiene información adicional si es necesario
  Future<List<FeedItem>> _processRawFeedItems(List<dynamic> rawItems) async {
    List<FeedItem> processedItems = [];
    final albumService = SpotifyAlbumService();
    final searchService = SpotifySearchService();
    
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
        // Si hay review, mostrarlo específicamente
        if (item['review'] != null && item['review'].toString().isNotEmpty) {
          debugPrint('[FEED_PROCESS] ✅ Review encontrada en datos originales: "${item['review']}"');
        }
          // Si no, recuperar los datos faltantes desde la API de Spotify
        if (idToUse.isNotEmpty) {
          // Si es un álbum
          if (contentType == 'album') {
            try {
              final albumDetails = await albumService.getAlbumDetails(idToUse);
              
              // Actualizar los datos faltantes
              title = albumDetails.name;
              artist = albumDetails.artistName;
              imageUrl = albumDetails.coverUrl;
              
              debugPrint('[FEED] Completados datos de álbum: $title por $artist');
            } catch (e) {
              debugPrint('[FEED][ERROR] Error al obtener datos del álbum $contentId: $e');
            }
          }          // Si es una canción, usamos searchService para buscar por ID
          else if (contentType == 'track') {
            try {
              // Realizar una búsqueda del track usando el ID como query
              await searchService.search('track:$idToUse', type: 'track');
              
              if (searchService.tracks.isNotEmpty) {
                final trackDetails = searchService.tracks.first;
                
                // Actualizar los datos faltantes
                title = trackDetails.name;
                artist = trackDetails.artistName;
                imageUrl = trackDetails.imageUrl;
                
                debugPrint('[FEED] Completados datos de canción: $title por $artist');
              }
            } catch (e) {
              debugPrint('[FEED][ERROR] Error al obtener datos de la canción $contentId: $e');
            }
          }
        }      // Verificar si el comentario existe en el objeto (inspeccionar todos los campos posibles)
        debugPrint('[FEED][DEBUG] Inspección de campos del item: ${item.keys.join(', ')}');
          // Buscar comentario en diferentes posibles campos
        String? reviewText = item['review'] as String?;
        
        // Si hay un comentario en review, verificar que no sea "null" como string
        if (reviewText != null) {
          if (reviewText.toLowerCase() == "null" || reviewText.isEmpty) {
            reviewText = null;
          }
        }
        
        // Probar con el campo comment si review no tiene valor
        if (reviewText == null) {
          reviewText = item['comment'] as String?;
          if (reviewText != null && (reviewText.toLowerCase() == "null" || reviewText.isEmpty)) {
            reviewText = null;
          }
        }
        
        // Imprimir para depuración lo que se encontró
        if (reviewText != null && reviewText.isNotEmpty) {
          debugPrint('[FEED] ✅ Comentario encontrado para item $contentId: "$reviewText"');
        } else {
          debugPrint('[FEED] ⚠️ NO se encontró comentario para item $contentId - Campos relevantes: review=${item['review']}, comment=${item['comment']}');
        }
          // Crear elemento con los datos originales pero actualizando los que faltaban
        final processedItem = FeedItem(
          id: item['id'] ?? '',
          contentId: contentId,
          contentType: contentType,
          title: title ?? 'Título desconocido',
          artist: artist ?? 'Artista desconocido',
          imageUrl: imageUrl ?? 'https://placeholder.com/400',
          rating: (item['rating'] as num?)?.toDouble() ?? 0.0,
          normalizedRating: (item['normalizedRating'] as num?)?.toDouble() ?? (item['rating'] as num?)?.toDouble() ?? 0.0,
          review: reviewText, // Usar la variable que puede venir de 'review' o 'comment'
          userId: item['userId'] ?? '',
          username: item['username'] ?? '',
          userImageUrl: item['userImage'] ?? '',
          timestamp: item['date'] != null 
            ? DateTime.parse(item['date']) 
            : DateTime.now(),
        );
        
        processedItems.add(processedItem);
      } catch (e) {
        debugPrint('[FEED][ERROR] Error al procesar elemento del feed: $e');
      }
    }
    
    return processedItems;
  }
  
  /// Obtiene el feed de calificaciones de un usuario específico
  /// 
  /// [userId] - ID del usuario del cual obtener las calificaciones
  /// [limit] - número máximo de ítems a obtener
  /// [offset] - índice desde el cual cargar (para paginación)
  Future<List<FeedItem>> getUserFeed(String userId, {int limit = 20, int offset = 0}) async {
    try {
      _setLoading(true);
      _setError(null);
        // Realizar solicitud al BFF
      final response = await _apiClient.get(
        '/feed/user/$userId?limit=$limit&offset=$offset'
      );
      
      debugPrint('[FEED] Respuesta del servidor (user feed): ${response.toString().substring(0, Math.min(500, response.toString().length))}...');
      
      // Procesar respuesta - Verificar las dos posibles estructuras: 'items' o 'data'
      List<dynamic>? feedData;
      if (response['items'] != null) {
        feedData = response['items'];
      } else if (response['data'] != null) {
        feedData = response['data'];
      }
      
      if (feedData != null && feedData.isNotEmpty) {
        // Procesar elementos del feed con el mismo método que usamos para el feed general
        final userFeed = await _processRawFeedItems(feedData);
        
        debugPrint('[FEED] Obtenidos ${userFeed.length} elementos del feed de usuario $userId');
        return userFeed;
      } else {
        _setError('No se encontraron elementos en el feed del usuario');
        debugPrint('[FEED][ERROR] $_errorMessage');
        return [];
      }
    } catch (e) {
      _setError('Error al cargar el feed de usuario: ${e.toString()}');
      debugPrint('[FEED][ERROR] $_errorMessage');
      return [];
    } finally {
      _setLoading(false);
      _safeNotify();
    }
  }
  
  /// Obtiene todos los elementos del feed (puede ser costoso, usar con precaución)
  Future<List<FeedItem>> getAllFeedItems() async {
    List<FeedItem> allItems = [];
    int currentOffset = 0;
    const int batchSize = 50;
    bool hasMoreItems = true;
    
    while (hasMoreItems) {
      final batch = await getFeed(limit: batchSize, offset: currentOffset);
      
      if (batch.isEmpty) {
        hasMoreItems = false;
      } else {
        allItems.addAll(batch);
        currentOffset += batchSize;
      }
    }
    
    return allItems;
  }
  
  /// Actualiza el feed obteniendo datos nuevos desde el servidor
  Future<void> refreshFeed() async {
    await getFeed();
  }
}
