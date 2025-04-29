import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Clase para gestionar el almacenamiento en caché de calificaciones
/// Utiliza el patrón Singleton para mantener una única instancia en toda la aplicación
class RatingCache {
  // Singleton pattern
  static final RatingCache _instance = RatingCache._internal();
  factory RatingCache() => _instance;
  
  // Claves para SharedPreferences
  static const String _albumRatingsKey = 'album_ratings_cache';
  static const String _trackRatingsKey = 'track_ratings_cache';
  static const String _albumTimestampsKey = 'album_timestamps_cache';
  static const String _trackTimestampsKey = 'track_timestamps_cache';
  
  // Cache para calificaciones de álbumes: Map<albumId, rating>
  final Map<String, double?> _albumRatings = {};
  
  // Cache para calificaciones de canciones: Map<trackId, rating>
  final Map<String, double?> _trackRatings = {};
  
  // Timestamp de cada calificación de álbum
  final Map<String, DateTime> _albumTimestamps = {};
  
  // Timestamp de cada calificación de canción
  final Map<String, DateTime> _trackTimestamps = {};
  
  // Tiempo de expiración de la caché (10 minutos)
  final Duration _cacheDuration = const Duration(minutes: 10);
  
  // Control de inicialización
  bool _initialized = false;
  bool _isLoading = false;
  
  RatingCache._internal() {
    // Cargar datos en segundo plano
    _loadFromStorage();
  }
  
  /// Carga las calificaciones desde SharedPreferences
  Future<void> _loadFromStorage() async {
    if (_isLoading) return;
    _isLoading = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar calificaciones de álbumes
      final albumRatingsJson = prefs.getString(_albumRatingsKey);
      if (albumRatingsJson != null) {
        final Map<String, dynamic> data = jsonDecode(albumRatingsJson);
        data.forEach((key, value) {
          if (value != null) {
            _albumRatings[key] = value is double ? value : double.tryParse(value.toString());
          } else {
            _albumRatings[key] = null;
          }
        });
      }
      
      // Cargar calificaciones de canciones
      final trackRatingsJson = prefs.getString(_trackRatingsKey);
      if (trackRatingsJson != null) {
        final Map<String, dynamic> data = jsonDecode(trackRatingsJson);
        data.forEach((key, value) {
          if (value != null) {
            _trackRatings[key] = value is double ? value : double.tryParse(value.toString());
          } else {
            _trackRatings[key] = null;
          }
        });
      }
      
      // Cargar timestamps de álbumes
      final albumTimestampsJson = prefs.getString(_albumTimestampsKey);
      if (albumTimestampsJson != null) {
        final Map<String, dynamic> data = jsonDecode(albumTimestampsJson);
        data.forEach((key, value) {
          if (value != null) {
            _albumTimestamps[key] = DateTime.fromMillisecondsSinceEpoch(value);
          }
        });
      }
      
      // Cargar timestamps de canciones
      final trackTimestampsJson = prefs.getString(_trackTimestampsKey);
      if (trackTimestampsJson != null) {
        final Map<String, dynamic> data = jsonDecode(trackTimestampsJson);
        data.forEach((key, value) {
          if (value != null) {
            _trackTimestamps[key] = DateTime.fromMillisecondsSinceEpoch(value);
          }
        });
      }
      
      _initialized = true;
      debugPrint('[CACHE] Loaded ${_albumRatings.length} album ratings and ${_trackRatings.length} track ratings from storage');
    } catch (e) {
      debugPrint('[ERROR] Failed to load ratings from storage: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  /// Guarda las calificaciones en SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convertir a formato json-serializable
      
      // Album ratings
      final Map<String, dynamic> albumRatingsData = {};
      _albumRatings.forEach((key, value) {
        albumRatingsData[key] = value;
      });
      await prefs.setString(_albumRatingsKey, jsonEncode(albumRatingsData));
      
      // Track ratings
      final Map<String, dynamic> trackRatingsData = {};
      _trackRatings.forEach((key, value) {
        trackRatingsData[key] = value;
      });
      await prefs.setString(_trackRatingsKey, jsonEncode(trackRatingsData));
      
      // Album timestamps
      final Map<String, dynamic> albumTimestampsData = {};
      _albumTimestamps.forEach((key, value) {
        albumTimestampsData[key] = value.millisecondsSinceEpoch;
      });
      await prefs.setString(_albumTimestampsKey, jsonEncode(albumTimestampsData));
      
      // Track timestamps
      final Map<String, dynamic> trackTimestampsData = {};
      _trackTimestamps.forEach((key, value) {
        trackTimestampsData[key] = value.millisecondsSinceEpoch;
      });
      await prefs.setString(_trackTimestampsKey, jsonEncode(trackTimestampsData));
      
      debugPrint('[CACHE] Saved ${_albumRatings.length} album ratings and ${_trackRatings.length} track ratings to storage');
    } catch (e) {
      debugPrint('[ERROR] Failed to save ratings to storage: $e');
    }
  }
  
  // Verificar si un álbum está en caché y no ha expirado
  bool hasValidAlbumRating(String albumId) {
    if (!_albumRatings.containsKey(albumId)) return false;
    if (!_albumTimestamps.containsKey(albumId)) return false;
    
    // Comprobar si ha expirado
    final timestamp = _albumTimestamps[albumId]!;
    return DateTime.now().difference(timestamp) <= _cacheDuration;
  }
  
  // Verificar si una canción está en caché y no ha expirado
  bool hasValidTrackRating(String trackId) {
    if (!_trackRatings.containsKey(trackId)) return false;
    if (!_trackTimestamps.containsKey(trackId)) return false;
    
    // Comprobar si ha expirado
    final timestamp = _trackTimestamps[trackId]!;
    return DateTime.now().difference(timestamp) <= _cacheDuration;
  }
  
  // Obtener calificación de álbum (null si no existe o ha expirado)
  double? getAlbumRating(String albumId) {
    if (!hasValidAlbumRating(albumId)) return null;
    return _albumRatings[albumId];
  }
  
  // Obtener calificación de canción (null si no existe o ha expirado)
  double? getTrackRating(String trackId) {
    if (!hasValidTrackRating(trackId)) return null;
    return _trackRatings[trackId];
  }
  
  // Guardar calificación de álbum
  void setAlbumRating(String albumId, double? rating) {
    _albumRatings[albumId] = rating;
    _albumTimestamps[albumId] = DateTime.now();
    debugPrint('[CACHE] Album rating cached: $albumId = $rating');
    
    // Guardar en storage
    _saveToStorage();
  }
  
  // Guardar calificación de canción
  void setTrackRating(String trackId, double? rating) {
    _trackRatings[trackId] = rating;
    _trackTimestamps[trackId] = DateTime.now();
    debugPrint('[CACHE] Track rating cached: $trackId = $rating');
    
    // Guardar en storage
    _saveToStorage();
  }
  
  // Limpiar toda la caché
  void clear() {
    _albumRatings.clear();
    _trackRatings.clear();
    _albumTimestamps.clear();
    _trackTimestamps.clear();
    debugPrint('[CACHE] Rating cache cleared');
    
    // Limpiar también el almacenamiento persistente
    _saveToStorage();
  }
  
  /// Limpia solo los elementos de cache más antiguos que la duración especificada
  void clearOldEntries([Duration? expiration]) {
    final expirationTime = expiration ?? _cacheDuration;
    final now = DateTime.now();
    
    // Cleanup for albums
    final oldAlbumKeys = _albumTimestamps.entries
        .where((entry) => now.difference(entry.value) > expirationTime)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in oldAlbumKeys) {
      _albumRatings.remove(key);
      _albumTimestamps.remove(key);
    }
    
    // Cleanup for tracks
    final oldTrackKeys = _trackTimestamps.entries
        .where((entry) => now.difference(entry.value) > expirationTime)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in oldTrackKeys) {
      _trackRatings.remove(key);
      _trackTimestamps.remove(key);
    }
    
    if (oldAlbumKeys.isNotEmpty || oldTrackKeys.isNotEmpty) {
      debugPrint('[CACHE] Cleared ${oldAlbumKeys.length} old album ratings and ${oldTrackKeys.length} old track ratings');
      
      // Actualizar almacenamiento persistente
      _saveToStorage();
    }
  }
  
  // Imprimir estadísticas de la caché (para depuración)
  void printStats() {
    debugPrint('[CACHE] Stats: ${_albumRatings.length} albums, ${_trackRatings.length} tracks');
  }
  
  /// Método público para guardar explícitamente en el almacenamiento
  Future<void> saveToStorage() async {
    debugPrint('[CACHE] Manually saving ratings to persistent storage');
    await _saveToStorage();
  }
  
  /// Limpia todas las calificaciones en caché
  Future<void> clearAll() async {
    debugPrint('[CACHE] Clearing all ratings');
    _albumRatings.clear();
    _trackRatings.clear();
    _albumTimestamps.clear();
    _trackTimestamps.clear();
    
    // Limpiar también el almacenamiento persistente
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_albumRatingsKey);
    await prefs.remove(_trackRatingsKey);
    await prefs.remove(_albumTimestampsKey);
    await prefs.remove(_trackTimestampsKey);
    
    debugPrint('[CACHE] All ratings cleared');
  }
}
