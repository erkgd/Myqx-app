import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/data/models/spotify_models.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';

class SpotifyAlbumService {
  final SpotifyAuthService _authService = SpotifyAuthService();

  // Método para obtener un álbum completo
  Future<SpotifyAlbum> getAlbumDetails(String albumId) async {
    if (albumId.isEmpty) {
      throw Exception('Album ID cannot be empty');
    }
    
    try {
      final token = await _authService.getAccessToken();
      
      // Asegurar que construimos una URI completa y válida
      final uri = Uri.parse('https://api.spotify.com/v1/albums/$albumId');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SpotifyAlbum.fromJson(data);
      } else {
        throw Exception('Failed to load album details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting album details: $e');
      throw Exception('Error getting album details: $e');
    }
  }

  // Método para obtener solo las pistas de un álbum
  Future<List<SpotifyTrack>> getAlbumTracks(String albumId) async {
    if (albumId.isEmpty) {
      throw Exception('Album ID cannot be empty');
    }
    
    try {
      final token = await _authService.getAccessToken();
      debugPrint("🎵 Cargando tracks del álbum: $albumId");
      
      // Usa market y limit para obtener todos los tracks
      final uri = Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks?market=ES&limit=50');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        debugPrint("✅ Se recibieron ${items.length} tracks de la API");
        
        // Aquí usamos el método correcto que SÍ existe
        return items.map((item) => SpotifyTrack.fromJson(item)).toList();
      } else {
        debugPrint("❌ Error en API: ${response.statusCode}");
        throw Exception('Failed to load album tracks: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting album tracks: $e');
      throw Exception('Error getting album tracks: $e');
    }
  }
}