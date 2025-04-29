import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/services/spotify_auth_service.dart';

/// Servicio para gestionar las acciones de "me gusta" de Spotify
class SpotifyLikeService {
  final SpotifyAuthService _authService;
  
  // Constructor
  SpotifyLikeService({SpotifyAuthService? authService}) 
      : _authService = authService ?? SpotifyAuthService();
      
  /// Maneja el caso de permisos insuficientes borrando las credenciales
  Future<void> _handleInsufficientScope() async {
    // Borrar credenciales para forzar una nueva autenticación con los scopes correctos
    await _authService.logout();
    
    debugPrint('[SPOTIFY_LIKE] 🔄 Credenciales borradas, se requerirá nueva autorización');
  }
  
  /// Marca un album como "me gusta" en Spotify
  /// 
  /// [albumId] - ID del álbum en Spotify
  /// Retorna true si la operación fue exitosa
  Future<bool> likeAlbum(String albumId) async {
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[SPOTIFY_LIKE] Error: No se pudo obtener el token de autenticación');
        return false;
      }
      
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/albums'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ids': [albumId],
        }),
      );
      
      final success = response.statusCode == 200 || response.statusCode == 201;
        if (success) {
        debugPrint('[SPOTIFY_LIKE] ✅ Album $albumId añadido a "me gusta" con éxito');
      } else {
        debugPrint('[SPOTIFY_LIKE] ❌ Error añadiendo album $albumId a "me gusta". Código: ${response.statusCode}');
        debugPrint('[SPOTIFY_LIKE] Respuesta: ${response.body}');
        
        // Si el error es por permisos insuficientes, borrar el token para forzar nueva autenticación
        if (response.statusCode == 403) {
          try {
            final responseBody = json.decode(response.body);
            if (responseBody['error']['message'] == 'Insufficient client scope') {
              debugPrint('[SPOTIFY_LIKE] ⚠️ Permisos insuficientes detectados, borrando credenciales...');
              await _handleInsufficientScope();
            }
          } catch (e) {
            debugPrint('[SPOTIFY_LIKE] Error al procesar respuesta de error: $e');
          }
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE] ❌ Error: $e');
      return false;
    }
  }
  
  /// Marca una pista/canción como "me gusta" en Spotify
  /// 
  /// [trackId] - ID de la pista en Spotify
  /// Retorna true si la operación fue exitosa
  Future<bool> likeTrack(String trackId) async {
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[SPOTIFY_LIKE] Error: No se pudo obtener el token de autenticación');
        return false;
      }
      
      final response = await http.put(
        Uri.parse('https://api.spotify.com/v1/me/tracks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ids': [trackId],
        }),
      );
        final success = response.statusCode == 200 || response.statusCode == 201;
      
      if (success) {
        debugPrint('[SPOTIFY_LIKE] ✅ Track $trackId añadida a "me gusta" con éxito');
      } else {
        debugPrint('[SPOTIFY_LIKE] ❌ Error añadiendo track $trackId a "me gusta". Código: ${response.statusCode}');
        debugPrint('[SPOTIFY_LIKE] Respuesta: ${response.body}');
        
        // Si el error es por permisos insuficientes, borrar el token para forzar nueva autenticación
        if (response.statusCode == 403) {
          try {
            final responseBody = json.decode(response.body);
            if (responseBody['error']['message'] == 'Insufficient client scope') {
              debugPrint('[SPOTIFY_LIKE] ⚠️ Permisos insuficientes detectados, borrando credenciales...');
              await _handleInsufficientScope();
            }
          } catch (e) {
            debugPrint('[SPOTIFY_LIKE] Error al procesar respuesta de error: $e');
          }
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE] ❌ Error: $e');
      return false;
    }
  }
  
  /// Verifica si un album está marcado como "me gusta" por el usuario actual
  /// 
  /// [albumId] - ID del álbum en Spotify
  /// Retorna true si el álbum está en "me gusta"
  Future<bool> isAlbumLiked(String albumId) async {
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[SPOTIFY_LIKE] Error: No se pudo obtener el token de autenticación');
        return false;
      }
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/albums/contains?ids=$albumId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        final isLiked = results.isNotEmpty && results[0] == true;
        debugPrint('[SPOTIFY_LIKE] Album $albumId like status: $isLiked');
        return isLiked;
      } else {
        debugPrint('[SPOTIFY_LIKE] ❌ Error verificando si album $albumId está en "me gusta". Código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE] ❌ Error: $e');
      return false;
    }
  }
  
  /// Verifica si una pista/canción está marcada como "me gusta" por el usuario actual
  /// 
  /// [trackId] - ID de la pista en Spotify
  /// Retorna true si la pista está en "me gusta"
  Future<bool> isTrackLiked(String trackId) async {
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[SPOTIFY_LIKE] Error: No se pudo obtener el token de autenticación');
        return false;
      }
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/tracks/contains?ids=$trackId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        final isLiked = results.isNotEmpty && results[0] == true;
        debugPrint('[SPOTIFY_LIKE] Track $trackId like status: $isLiked');
        return isLiked;
      } else {
        debugPrint('[SPOTIFY_LIKE] ❌ Error verificando si track $trackId está en "me gusta". Código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE] ❌ Error: $e');
      return false;
    }
  }
  
  /// Quita un álbum de "me gusta" en Spotify
  /// 
  /// [albumId] - ID del álbum en Spotify
  /// Retorna true si la operación fue exitosa
  Future<bool> unlikeAlbum(String albumId) async {
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[SPOTIFY_LIKE] Error: No se pudo obtener el token de autenticación');
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('https://api.spotify.com/v1/me/albums'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ids': [albumId],
        }),
      );
      
      final success = response.statusCode == 200;
      
      if (success) {
        debugPrint('[SPOTIFY_LIKE] ✅ Album $albumId quitado de "me gusta" con éxito');
      } else {
        debugPrint('[SPOTIFY_LIKE] ❌ Error quitando album $albumId de "me gusta". Código: ${response.statusCode}');
        debugPrint('[SPOTIFY_LIKE] Respuesta: ${response.body}');
        
        if (response.statusCode == 403) {
          // Verificar si es un problema de permisos insuficientes
          try {
            final error = json.decode(response.body);
            if (error is Map && error['error'] is Map && 
                error['error']['message'] == 'Insufficient client scope') {
              debugPrint('[SPOTIFY_LIKE] ⚠️ Permisos insuficientes, se intentará renovar la autenticación');
              await _handleInsufficientScope();
            }
          } catch (e) {
            debugPrint('[SPOTIFY_LIKE] Error al procesar respuesta de error: $e');
          }
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE] ❌ Error: $e');
      return false;
    }
  }

  /// Quita una pista/canción de "me gusta" en Spotify
  /// 
  /// [trackId] - ID de la pista en Spotify
  /// Retorna true si la operación fue exitosa
  Future<bool> unlikeTrack(String trackId) async {
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        debugPrint('[SPOTIFY_LIKE] Error: No se pudo obtener el token de autenticación');
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('https://api.spotify.com/v1/me/tracks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ids': [trackId],
        }),
      );
      
      final success = response.statusCode == 200;
      
      if (success) {
        debugPrint('[SPOTIFY_LIKE] ✅ Track $trackId quitada de "me gusta" con éxito');
      } else {
        debugPrint('[SPOTIFY_LIKE] ❌ Error quitando track $trackId de "me gusta". Código: ${response.statusCode}');
        debugPrint('[SPOTIFY_LIKE] Respuesta: ${response.body}');
        
        if (response.statusCode == 403) {
          // Verificar si es un problema de permisos insuficientes
          try {
            final error = json.decode(response.body);
            if (error is Map && error['error'] is Map && 
                error['error']['message'] == 'Insufficient client scope') {
              debugPrint('[SPOTIFY_LIKE] ⚠️ Permisos insuficientes, se intentará renovar la autenticación');
              await _handleInsufficientScope();
            }
          } catch (e) {
            debugPrint('[SPOTIFY_LIKE] Error al procesar respuesta de error: $e');
          }
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('[SPOTIFY_LIKE] ❌ Error: $e');
      return false;
    }
  }
  
  /// Método genérico para dar me gusta a un contenido (album o track)
  /// 
  /// [contentId] - ID del contenido en Spotify
  /// [contentType] - Tipo de contenido ('album' o 'track')
  /// Retorna true si la operación fue exitosa
  Future<bool> likeContent(String contentId, String contentType) async {
    if (contentType.toLowerCase() == 'album') {
      return await likeAlbum(contentId);
    } else if (contentType.toLowerCase() == 'track') {
      return await likeTrack(contentId);
    }
    
    debugPrint('[SPOTIFY_LIKE] ❌ Tipo de contenido no soportado: $contentType');
    return false;
  }
  
  /// Verifica si un contenido está marcado como "me gusta"
  /// 
  /// [contentId] - ID del contenido en Spotify
  /// [contentType] - Tipo de contenido ('album' o 'track')
  /// Retorna true si el contenido está en "me gusta"
  Future<bool> isContentLiked(String contentId, String contentType) async {
    if (contentType.toLowerCase() == 'album') {
      return await isAlbumLiked(contentId);
    } else if (contentType.toLowerCase() == 'track') {
      return await isTrackLiked(contentId);
    }
    
    debugPrint('[SPOTIFY_LIKE] ❌ Tipo de contenido no soportado: $contentType');
    return false;
  }
  
  /// Método genérico para alternar "me gusta" de un contenido (album o track)
  /// 
  /// [contentId] - ID del contenido en Spotify
  /// [contentType] - Tipo de contenido ('album' o 'track')
  /// [isCurrentlyLiked] - Si el contenido está actualmente en "me gusta"
  /// Retorna true si la operación fue exitosa
  Future<bool> toggleLike(String contentId, String contentType, bool isCurrentlyLiked) async {
    if (isCurrentlyLiked) {
      // Si ya está en favoritos, quitarlo
      if (contentType.toLowerCase() == 'album') {
        return await unlikeAlbum(contentId);
      } else if (contentType.toLowerCase() == 'track') {
        return await unlikeTrack(contentId);
      }
    } else {
      // Si no está en favoritos, añadirlo
      return await likeContent(contentId, contentType);
    }
    
    debugPrint('[SPOTIFY_LIKE] ❌ Tipo de contenido no soportado: $contentType');
    return false;
  }
}
