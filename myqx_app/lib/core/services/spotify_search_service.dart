import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';

class SpotifySearchService with ChangeNotifier {
  final SpotifyAuthService _authService = SpotifyAuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<SpotifyTrack> _tracks = [];
  List<SpotifyAlbum> _albums = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SpotifyTrack> get tracks => _tracks;
  List<SpotifyAlbum> get albums => _albums;
  
  Future<void> search(String query, {String type = 'track,album'}) async {
    if (query.isEmpty) {
      _tracks = [];
      _albums = [];
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
        }
        
        // Process albums
        if (data.containsKey('albums')) {
          final List<dynamic> albumItems = data['albums']['items'];
          _albums = albumItems.map((item) => SpotifyAlbum.fromJson(item)).toList();
          //debugPrint(_albums.toString());
        }
        
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to search: ${response.reasonPhrase}';
        _tracks = [];
        _albums = [];
      }
    } catch (e) {
      _errorMessage = 'Error during search: $e';
      _tracks = [];
      _albums = [];
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearResults() {
    _tracks = [];
    _albums = [];
    _errorMessage = null;
    notifyListeners();
  }
}