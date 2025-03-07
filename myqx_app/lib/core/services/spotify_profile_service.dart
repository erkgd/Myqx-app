import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/constants/spotify_constants.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';


class SpotifyProfileService with ChangeNotifier {
  final SpotifyAuthService _authService = SpotifyAuthService();
  
  SpotifyUser? _currentUser;
  List<SpotifyTrack> _topTracks = [];
  List<SpotifyAlbum> _topAlbums = [];
  SpotifyTrack? _starOfTheDay;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  SpotifyUser? get currentUser => _currentUser;
  List<SpotifyTrack> get topTracks => _topTracks;
  List<SpotifyAlbum> get topAlbums => _topAlbums;
  SpotifyTrack? get starOfTheDay => _starOfTheDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialize the service and load data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadUserProfile();
      await Future.wait([
        _loadTopTracks(),
        _loadTopAlbums(),
      ]);
      _pickStarOfTheDay();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load profile data: ${e.toString()}";
      debugPrint("[ERROR] SpotifyProfileService: $_errorMessage");
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Load user profile from Spotify API
  Future<void> _loadUserProfile() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = SpotifyUser.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load user profile: $e");
      rethrow;
    }
  }
  
  // Load user's top tracks from Spotify API
  Future<void> _loadTopTracks() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me/top/tracks?limit=10&time_range=medium_term'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _topTracks = (data['items'] as List)
            .map((item) => SpotifyTrack.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load top tracks: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load top tracks: $e");
      rethrow;
    }
  }
  
  // Extract albums from top tracks and deduplicate
  Future<void> _loadTopAlbums() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) throw Exception('Not authenticated');
      
      final response = await http.get(
        Uri.parse('${SpotifyConstants.apiUrl}/me/top/tracks?limit=50&time_range=long_term'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracks = (data['items'] as List);
        
        // Extract unique albums from the tracks
        final Map<String, SpotifyAlbum> albumsMap = {};
        
        for (var track in tracks) {
          final album = track['album'];
          final albumId = album['id'];
          
          if (!albumsMap.containsKey(albumId)) {
            albumsMap[albumId] = SpotifyAlbum(
              id: albumId,
              name: album['name'],
              artistName: album['artists'][0]['name'],
              coverUrl: album['images'][0]['url'],
              spotifyUrl: album['external_urls']['spotify'],
            );
          }
        }
        
        // Convert map to list and take top 5
        _topAlbums = albumsMap.values.toList();
        _topAlbums.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically for now
        if (_topAlbums.length > 5) {
          _topAlbums = _topAlbums.sublist(0, 5);
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load top albums: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load top albums: $e");
      rethrow;
    }
  }
  
  // Pick a random track as "star of the day"
  void _pickStarOfTheDay() {
    if (_topTracks.isNotEmpty) {
      // For now, just pick the first track as the star
      _starOfTheDay = _topTracks.first;
      notifyListeners();
    }
  }
  
  // Calculate compatibility with another user (placeholder for now)
  int calculateCompatibility() {
    // This would normally compare music tastes with another user
    // For now, return a random percentage
    return (DateTime.now().millisecond % 101); // 0-100
  }
}