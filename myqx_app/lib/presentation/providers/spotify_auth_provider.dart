import 'package:flutter/material.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Provider para manejar la autenticación y datos de Spotify en la UI
class SpotifyAuthProvider extends ChangeNotifier {
  final SpotifyAuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;
  SpotifyUser? _currentUser;
  List<SpotifyTrack>? _topTracks;
  String? _accessToken;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SpotifyUser? get currentUser => _currentUser;
  List<SpotifyTrack>? get topTracks => _topTracks;
  bool get isAuthenticated => _authService.isAuthenticated.value;
  String? get accessToken => _accessToken;
  
  // Constructor con inyección de dependencias para testing
  SpotifyAuthProvider({SpotifyAuthService? authService})
      : _authService = authService ?? SpotifyAuthService() {
    // Escuchar cambios en el estado de autenticación
    _authService.isAuthenticated.addListener(_onAuthStateChanged);
    
    // Cargar datos de usuario si ya está autenticado
    if (_authService.isAuthenticated.value) {
      _refreshToken();
      fetchUserData();
    }
  }

  // Método para refrescar el token
  Future<void> _refreshToken() async {
    _accessToken = await _authService.getAccessToken();
  }
  
  // Método para iniciar sesión con Spotify
  Future<bool> login() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final success = await _authService.login();
      if (success) {
        await _refreshToken();
        await fetchUserData();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.logout();
      _currentUser = null;
      _topTracks = null;
      _accessToken = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Obtener datos del usuario actual
  Future<void> fetchUserData() async {
    if (!_authService.isAuthenticated.value) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final token = await _authService.getAccessToken();
      if (token == null) {
        _errorMessage = 'No se pudo obtener el token de acceso';
        notifyListeners();
        return;
      }
      
      _accessToken = token;
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = SpotifyUser.fromJson(userData);
      } else {
        _errorMessage = 'Error al obtener datos del usuario: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error al obtener datos del usuario: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Obtener las canciones más escuchadas por el usuario
  Future<void> fetchTopTracks() async {
    if (!_authService.isAuthenticated.value) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final token = await _authService.getAccessToken();
      if (token == null) {
        _errorMessage = 'No se pudo obtener el token de acceso';
        notifyListeners();
        return;
      }
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?limit=20&time_range=medium_term'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        _topTracks = items.map((item) => SpotifyTrack.fromJson(item)).toList();
      } else {
        _errorMessage = 'Error al obtener las canciones favoritas: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error al obtener las canciones favoritas: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Observador para cambios en el estado de autenticación
  void _onAuthStateChanged() {
    notifyListeners();
    if (_authService.isAuthenticated.value && _currentUser == null) {
      _refreshToken();
      fetchUserData();
    }
  }
  
  @override
  void dispose() {
    // Remover listener para evitar memory leaks
    _authService.isAuthenticated.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}