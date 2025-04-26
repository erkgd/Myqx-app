import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';

/// Clase para almacenar resultados de búsqueda en caché
class _CachedSearchResult {
  final List<SpotifyTrack> tracks;
  final List<SpotifyAlbum> albums;
  final DateTime timestamp;
  
  _CachedSearchResult(this.tracks, this.albums) : timestamp = DateTime.now();
  
  bool isExpired(Duration cacheDuration) {
    return DateTime.now().difference(timestamp) > cacheDuration;
  }
}

class SpotifySearchService with ChangeNotifier {
  final SpotifyAuthService _authService;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<SpotifyTrack> _tracks = [];
  List<SpotifyAlbum> _albums = [];
  
  // Sistema de caché para búsquedas
  final Map<String, _CachedSearchResult> _searchCache = {};
  // Tiempo de expiración de la caché (30 minutos)
  final Duration _cacheDuration = const Duration(minutes: 30);
  
  // Constructor que permite inicialización perezosa
  SpotifySearchService({bool lazyInit = false}) : _authService = SpotifyAuthService();
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SpotifyTrack> get tracks => _tracks;
  List<SpotifyAlbum> get albums => _albums;
  
  // Clave para la caché basada en la consulta y el tipo
  String _getCacheKey(String query, String type) => '$query:$type';
  
  Future<void> search(String query, {String type = 'track,album'}) async {
    if (query.isEmpty) {
      _tracks = [];
      _albums = [];
      notifyListeners();
      return;
    }
    
    final cacheKey = _getCacheKey(query, type);
    
    // Verificar si existe en caché y no ha expirado
    final cachedResult = _searchCache[cacheKey];
    if (cachedResult != null && !cachedResult.isExpired(_cacheDuration)) {
      debugPrint('[DEBUG] Using cached search results for: $query ($type)');
      _tracks = cachedResult.tracks;
      _albums = cachedResult.albums;
      _errorMessage = null;
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    
    try {
      final token = await _authService.getAccessToken();
      
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      // Encode query for URL
      final encodedQuery = Uri.encodeComponent(query);
      
      debugPrint('[DEBUG] Performing Spotify search: $query ($type)');
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$encodedQuery&type=$type&limit=10'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Process tracks
        if (data.containsKey('tracks')) {
          final List<dynamic> trackItems = data['tracks']['items'];
          _tracks = trackItems.map((item) => SpotifyTrack.fromJson(item)).toList();
        } else {
          _tracks = [];
        }
        
        // Process albums
        if (data.containsKey('albums')) {
          final List<dynamic> albumItems = data['albums']['items'];
          _albums = albumItems.map((item) => SpotifyAlbum.fromJson(item)).toList();
        } else {
          _albums = [];
        }
        
        // Guardar resultados en caché
        _searchCache[cacheKey] = _CachedSearchResult(List.from(_tracks), List.from(_albums));
        debugPrint('[DEBUG] Search results cached for: $query ($type)');
        
        _errorMessage = null;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[ERROR] Spotify search error: $_errorMessage');
    } finally {
      _setLoading(false);
    }
  }
  
  void clearResults() {
    _tracks = [];
    _albums = [];
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearCache() {
    _searchCache.clear();
    debugPrint('[DEBUG] Search cache cleared');
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}