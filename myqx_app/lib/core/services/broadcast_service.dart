import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
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
      
      // Procesar respuesta
      if (response['feed'] != null) {
        final List<dynamic> feedData = response['feed'];
        
        _feedItems = feedData.map((item) => FeedItem.fromJson(item)).toList();
        
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
      
      // Procesar respuesta
      if (response['feed'] != null) {
        final List<dynamic> feedData = response['feed'];
        
        final userFeed = feedData.map((item) => FeedItem.fromJson(item)).toList();
        
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
