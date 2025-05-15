import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';

/// Servicio para obtener y manipular información de pistas de Spotify
class SpotifyTrackService {
  final SpotifyAuthService _authService;
  
  // Cache para detalles de pistas
  static final Map<String, Map<String, dynamic>> _trackDetailsCache = {};
  static final Map<String, DateTime> _trackDetailsFetchTime = {};
  static const Duration _cacheDuration = Duration(days: 7); // 7 días de caché para tracks
  
  SpotifyTrackService({SpotifyAuthService? authService}) 
      : _authService = authService ?? SpotifyAuthService();
  
  /// Obtiene los detalles de una pista específica por su ID
  /// Retorna un objeto SpotifyTrack o null si ocurre algún error
  Future<SpotifyTrack?> getTrackById(String trackId) async {
    if (trackId.isEmpty) {
      debugPrint('[ERROR] Track ID vacío');
      return null;
    }
    
    try {
      final trackDetails = await _getTrackDetailsFromApi(trackId);
      if (trackDetails == null) {
        return null;
      }
      
      return _convertJsonToTrack(trackDetails);
    } catch (e) {
      debugPrint('[ERROR] Error al obtener track $trackId: $e');
      return null;
    }
  }
  
  /// Obtiene los detalles de varias pistas por sus IDs
  /// Retorna una lista de SpotifyTrack, omitiendo las que no se pudieron obtener
  Future<List<SpotifyTrack>> getTracksById(List<String> trackIds) async {
    if (trackIds.isEmpty) {
      return [];
    }
    
    // Limitar a 50 IDs por petición (límite de la API de Spotify)
    if (trackIds.length > 50) {
      trackIds = trackIds.sublist(0, 50);
    }
    
    final results = <SpotifyTrack>[];
    
    try {
      // Intentar usar el endpoint de múltiples tracks
      final detailsList = await _getMultipleTrackDetailsFromApi(trackIds);
      
      if (detailsList != null) {
        for (final details in detailsList) {
          final track = _convertJsonToTrack(details);
          if (track != null) {
            results.add(track);
          }
        }
      } else {
        // Si falla, intentar obtener uno por uno
        for (final id in trackIds) {
          final track = await getTrackById(id);
          if (track != null) {
            results.add(track);
          }
        }
      }
    } catch (e) {
      debugPrint('[ERROR] Error al obtener tracks por IDs: $e');
    }
    
    return results;
  }
  
  /// Método interno para obtener detalles de una pista de la API de Spotify
  Future<Map<String, dynamic>?> _getTrackDetailsFromApi(String trackId) async {
    // Verificar si tenemos los detalles en caché y no han expirado
    final bool hasCachedData = _trackDetailsCache.containsKey(trackId);
    final bool isCacheValid = hasCachedData && 
        (_trackDetailsFetchTime[trackId]?.isAfter(DateTime.now().subtract(_cacheDuration)) ?? false);
    
    if (isCacheValid) {
      debugPrint('[DEBUG] Usando datos en caché para track $trackId');
      return _trackDetailsCache[trackId];
    }
    
    try {
      // Obtener token de autenticación para Spotify
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[ERROR] No se pudo obtener el token de autenticación de Spotify');
        return null;
      }
      
      // Realizar petición directa al endpoint de tracks de Spotify
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Guardar en caché
        _trackDetailsCache[trackId] = data;
        _trackDetailsFetchTime[trackId] = DateTime.now();
        
        debugPrint('[DEBUG] Detalles de track obtenidos con éxito: ${data['name']}');
        return data;
      } else {
        debugPrint('[ERROR] Error al obtener datos de track. Código: ${response.statusCode}');
        debugPrint('[ERROR] Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[ERROR] Error al obtener detalles del track $trackId: $e');
      return null;
    }
  }
  
  /// Método interno para obtener detalles de múltiples pistas en una sola petición
  Future<List<Map<String, dynamic>>?> _getMultipleTrackDetailsFromApi(List<String> trackIds) async {
    if (trackIds.isEmpty) {
      return [];
    }
    
    try {
      // Obtener token de autenticación para Spotify
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[ERROR] No se pudo obtener el token de autenticación de Spotify');
        return null;
      }
      
      // Construir el parámetro ids (comma-separated)
      final ids = trackIds.join(',');
      
      // Realizar petición al endpoint de several tracks de Spotify
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks?ids=$ids'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['tracks'] == null || !(data['tracks'] is List)) {
          debugPrint('[ERROR] Formato de respuesta inesperado');
          return null;
        }
        
        final tracksList = data['tracks'] as List;
        final results = <Map<String, dynamic>>[];
        
        for (final track in tracksList) {
          if (track != null) {
            // Guardar en caché
            final trackId = track['id'];
            if (trackId != null) {
              _trackDetailsCache[trackId] = track;
              _trackDetailsFetchTime[trackId] = DateTime.now();
            }
            
            results.add(track);
          }
        }
        
        debugPrint('[DEBUG] Obtenidos ${results.length} tracks en una sola petición');
        return results;
      } else {
        debugPrint('[ERROR] Error al obtener múltiples tracks. Código: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[ERROR] Error al obtener múltiples tracks: $e');
      return null;
    }
  }
  
  /// Convierte los datos JSON de Spotify a un objeto SpotifyTrack
  SpotifyTrack? _convertJsonToTrack(Map<String, dynamic> json) {
    try {
      String? imageUrl;
      String albumName = '';
      String? albumId;
      
      if (json['album'] != null) {
        albumName = json['album']['name'] ?? '';
        albumId = json['album']['id'];
        
        if (json['album']['images'] != null && json['album']['images'].isNotEmpty) {
          imageUrl = json['album']['images'][0]['url'];
        }
      }
      
      String artistName = 'Artista desconocido';
      if (json['artists'] != null && json['artists'].isNotEmpty) {
        artistName = json['artists'][0]['name'];
      }
      
      return SpotifyTrack(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Pista desconocida',
        artistName: artistName,
        albumName: albumName,
        imageUrl: imageUrl,
        spotifyUrl: json['external_urls']?['spotify'] ?? '',
        albumId: albumId,
        previewUrl: json['preview_url'],
      );
    } catch (e) {
      debugPrint('[ERROR] Error al convertir JSON a SpotifyTrack: $e');
      return null;
    }
  }
  
  /// Limpia la caché de detalles de pistas
  void clearCache() {
    _trackDetailsCache.clear();
    _trackDetailsFetchTime.clear();
    debugPrint('[DEBUG] Caché de tracks limpiada');
  }
  
  /// Limpia la caché de tracks específicos por ID
  void clearCacheForTracks(List<String> trackIds) {
    if (trackIds.isEmpty) return;
    
    int cleared = 0;
    for (final trackId in trackIds) {
      if (_trackDetailsCache.containsKey(trackId)) {
        _trackDetailsCache.remove(trackId);
        _trackDetailsFetchTime.remove(trackId);
        cleared++;
      }
    }
    debugPrint('[DEBUG] Se limpió la caché para $cleared/${trackIds.length} tracks');
  }
}
