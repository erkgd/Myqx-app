import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/services/search_service.dart';
import 'package:myqx_app/core/utils/rating_cache.dart';
import 'package:myqx_app/core/utils/scroll_optimizer.dart';

/// Clase utilitaria para precarga y gestión eficiente de calificaciones
class RatingManager {
  // Singleton pattern
  static final RatingManager _instance = RatingManager._internal();
  factory RatingManager() => _instance;
  
  final SearchService _searchService = SearchService();
  final ScrollOptimizer _scrollOptimizer = ScrollOptimizer();
  bool _isPreloading = false;
  
  // Para evitar cargas múltiples de los mismos IDs
  final Set<String> _recentlyRequestedAlbumIds = {};
  final Set<String> _recentlyRequestedTrackIds = {};
  
  RatingManager._internal() {
    // Configurar limpieza periódica de cachés antiguas
    _setupPeriodicCacheCleanup();
  }
  
  /// Configura la limpieza periódica de elementos de caché antiguos
  void _setupPeriodicCacheCleanup() {
    // Limpiar cachés antiguas cada 10 minutos
    Future.delayed(const Duration(minutes: 10), () {
      try {
        RatingCache().clearOldEntries();
        _recentlyRequestedAlbumIds.clear();
        _recentlyRequestedTrackIds.clear();
        debugPrint('[RATING] Performed periodic cache cleanup');
      } catch (e) {
        debugPrint('[ERROR] Error during periodic cache cleanup: $e');
      } finally {
        // Programar la siguiente limpieza
        _setupPeriodicCacheCleanup();
      }
    });
  }
  
  /// Precargar calificaciones de álbumes en batches para optimizar el rendimiento
  /// Útil cuando sabemos que el usuario va a ver muchos álbumes/canciones
  Future<void> preloadAlbumRatings(List<String> albumIds) async {
    if (_isPreloading || albumIds.isEmpty) return;
    
    // Solo ejecutar cuando el scroll se haya detenido
    _scrollOptimizer.executeWhenScrollPaused(() async {
      try {
        _isPreloading = true;
        
        // Filtrar IDs que no están en caché y que no se pidieron recientemente
        final albumsToLoad = albumIds.where((id) => 
          !RatingCache().hasValidAlbumRating(id) && 
          !_recentlyRequestedAlbumIds.contains(id)
        ).toList();
        
        if (albumsToLoad.isEmpty) {
          debugPrint('[RATING] No new album ratings to load (${albumIds.length} total)');
          return;
        }
        
        // Registrar los IDs que se están solicitando para evitar duplicados
        _recentlyRequestedAlbumIds.addAll(albumsToLoad);
        
        // Limitar el número de peticiones para no sobrecargar el servidor
        final limitedAlbums = albumsToLoad.length > 10 ? 
          albumsToLoad.sublist(0, 10) : albumsToLoad;
          
        debugPrint('[RATING] Preloading ${limitedAlbums.length} album ratings');
        
        // Cargar en paralelo con un límite de 3 peticiones simultáneas
        final chunks = _splitIntoChunks(limitedAlbums, 3);
        for (final chunk in chunks) {
          await Future.wait(
            chunk.map((id) => _searchService.getAlbumRating(id))
          );
        }
        
        debugPrint('[RATING] Preloaded ${limitedAlbums.length} album ratings successfully');
        
        // Limpiar registros antiguos después de 30 segundos
        Future.delayed(const Duration(seconds: 30), () {
          for (final id in albumsToLoad) {
            _recentlyRequestedAlbumIds.remove(id);
          }
        });
      } catch (e) {
        debugPrint('[ERROR] Error preloading album ratings: $e');
      } finally {
        _isPreloading = false;
      }
    });
  }
    /// Precargar calificaciones de canciones en batches para optimizar el rendimiento
  Future<void> preloadTrackRatings(List<String> trackIds) async {
    if (_isPreloading || trackIds.isEmpty) return;
    
    // Solo ejecutar cuando el scroll se haya detenido
    _scrollOptimizer.executeWhenScrollPaused(() async {
      try {
        _isPreloading = true;
        
        // Filtrar IDs que no están en caché y que no se pidieron recientemente
        final tracksToLoad = trackIds.where((id) => 
          !RatingCache().hasValidTrackRating(id) && 
          !_recentlyRequestedTrackIds.contains(id)
        ).toList();
        
        if (tracksToLoad.isEmpty) {
          debugPrint('[RATING] No new track ratings to load (${trackIds.length} total)');
          return;
        }
        
        // Registrar los IDs que se están solicitando para evitar duplicados
        _recentlyRequestedTrackIds.addAll(tracksToLoad);
        
        // Limitar el número de peticiones para no sobrecargar el servidor
        final limitedTracks = tracksToLoad.length > 10 ? 
          tracksToLoad.sublist(0, 10) : tracksToLoad;
          
        debugPrint('[RATING] Preloading ${limitedTracks.length} track ratings');
        
        // Cargar en paralelo con un límite de 3 peticiones simultáneas
        final chunks = _splitIntoChunks(limitedTracks, 3);
        for (final chunk in chunks) {
          await Future.wait(
            chunk.map((id) => _searchService.getSongRating(id))
          );
        }
        
        // Verificar estadísticas de caché después de cargar
        RatingCache().printStats();
        
        debugPrint('[RATING] Preloaded ${limitedTracks.length} track ratings successfully');
        
        // Limpiar registros antiguos después de 30 segundos
        Future.delayed(const Duration(seconds: 30), () {
          for (final id in tracksToLoad) {
            _recentlyRequestedTrackIds.remove(id);
          }
        });
      } catch (e) {
        debugPrint('[ERROR] Error preloading track ratings: $e');
      } finally {
        _isPreloading = false;
      }
    });
  }
  
  /// Método para dividir una lista en chunks de tamaño específico
  List<List<T>> _splitIntoChunks<T>(List<T> list, int chunkSize) {
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      result.add(
        list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize)
      );
    }
    return result;
  }
  
  /// Fuerza la persistencia de las calificaciones en almacenamiento local
  /// Llamar este método cuando el usuario termina una sesión de calificación
  void persistRatings() {
    // RatingCache ya guarda automáticamente cada cambio,
    // pero podemos forzar una limpieza y notificar para
    // visualizar claramente cuando persistimos los datos
    
    // Limpiar IDs temporales que ya no necesitamos
    _recentlyRequestedAlbumIds.clear();
    _recentlyRequestedTrackIds.clear();
    
    // Imprimir estadísticas para debug
    RatingCache().printStats();
    
    debugPrint('[RATING] Ratings persisted to local storage');
  }
}
