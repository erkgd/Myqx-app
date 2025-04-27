import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/constants/spotify_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 

class SpotifyAuthService {
  // Reemplaza estos valores con tu configuración de Spotify Developer
  static const String _clientId = SpotifyConstants.clientId;
  static const String _redirectUri = SpotifyConstants.redirectUri;
  
  // Scope necesario para acceder a datos del usuario y de música
  static const String _scope = 'user-read-email user-read-private user-top-read user-library-read';
  
  // Claves para almacenamiento local
  static const String _accessTokenKey = 'spotify_access_token';
  static const String _refreshTokenKey = 'spotify_refresh_token';
  static const String _expiresAtKey = 'spotify_expires_at';
  
  // URLs de Spotify
  static const String _authUrl = SpotifyConstants.authUrl;
  static const String _tokenUrl = SpotifyConstants.tokenUrl;
  
  // Estado de autenticación
  ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  
  // Variables para controlar verificaciones de autenticación
  bool _isCheckingAuth = false;
  DateTime? _lastAuthCheck;
  String? _cachedToken;
  DateTime? _cachedTokenExpiry;
  
  // Singleton pattern
  static final SpotifyAuthService _instance = SpotifyAuthService._internal();
  
  factory SpotifyAuthService() {
    return _instance;
  }
  
  SpotifyAuthService._internal() {
    // Iniciar verificación de autenticación de manera asíncrona
    Future.microtask(() => _checkAuth());
  }
  
  // Verificar si ya está autenticado al inicializar
  Future<void> _checkAuth() async {
    // Evitar múltiples verificaciones simultáneas
    if (_isCheckingAuth) return;
    
    // Si se verificó hace menos de 1 minuto, usar el resultado en caché
    if (_lastAuthCheck != null && 
        DateTime.now().difference(_lastAuthCheck!) < Duration(minutes: 1)) {
      debugPrint('[DEBUG] Using cached auth status: ${isAuthenticated.value}');
      return;
    }
    
    _isCheckingAuth = true;
    _lastAuthCheck = DateTime.now();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      final expiresAtStr = prefs.getString(_expiresAtKey);
      
      if (accessToken != null && expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (expiresAt.isAfter(DateTime.now())) {
          // Update the cached token
          _cachedToken = accessToken;
          _cachedTokenExpiry = expiresAt;
          isAuthenticated.value = true;
        } else {
          // Token expirado, intentar refrescar
          final refreshToken = prefs.getString(_refreshTokenKey);
          if (refreshToken != null) {
            try {
              await _refreshAccessToken(refreshToken);
              isAuthenticated.value = true;
            } catch (e) {
              isAuthenticated.value = false;
            }
          } else {
            isAuthenticated.value = false;
          }
        }
      } else {
        isAuthenticated.value = false;
      }
    } catch (e) {
      debugPrint('[ERROR] Error checking auth state: $e');
      isAuthenticated.value = false;
    } finally {
      _isCheckingAuth = false;
    }
  }
  
  // Generar estado aleatorio para seguridad
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  Future<bool> _isSpotifyInstalled() async {
    final spotifyUri = Uri.parse('spotify:');
    try {
      return await canLaunchUrl(spotifyUri);
    } catch (e) {
      debugPrint('[ERROR] Error checking if Spotify is installed: $e');
      return false;
    }
  }
  
  /// Login using Spotify OAuth
  Future<bool> login() async {
    if (isAuthenticated.value) {
      debugPrint('[DEBUG] Already authenticated with Spotify');
      return true;
    }
    
    isLoading.value = true;
    try {
      // Generate a random state string for CSRF protection
      final state = _generateRandomString(16);
      
      // Build auth URL with proper parameters
      final authUrl = Uri.parse(_authUrl).replace(
        queryParameters: {
          'client_id': _clientId,
          'response_type': 'code',
          'redirect_uri': _redirectUri,
          'state': state,
          'scope': _scope,
          'show_dialog': 'true',
        },
      );
      
      debugPrint('[DEBUG] Opening auth URL: $authUrl');
      
      // Launch auth flow
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: Uri.parse(_redirectUri).scheme,
      );
      
      debugPrint('[DEBUG] Auth flow complete: $result');
      
      // Extract code from response
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('No authorization code received');
      }
      
      // Get token using the authorization code
      await _getAccessToken(code);
      isAuthenticated.value = true;
      return true;
    } catch (e) {
      debugPrint('[ERROR] Spotify login failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Logout from Spotify
  Future<void> logout() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove stored tokens
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_expiresAtKey);
      
      // Clear cached values
      _cachedToken = null;
      _cachedTokenExpiry = null;
      
      isAuthenticated.value = false;
      debugPrint('[DEBUG] Spotify logout successful');
    } catch (e) {
      debugPrint('[ERROR] Error during Spotify logout: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _getAccessToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:${SpotifyConstants.clientSecret}')),
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
          'client_id': _clientId,
          'client_secret': SpotifyConstants.clientSecret,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(
          data['access_token'],
          data['refresh_token'],
          data['expires_in'],
        );
      } else {
        throw Exception('Error getting access token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ERROR] Error getting access token: $e');
      throw e;
    }
  }
  
  Future<void> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:${SpotifyConstants.clientSecret}')),
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
          'client_secret': SpotifyConstants.clientSecret,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Spotify might not return a new refresh token
        final newRefreshToken = data['refresh_token'] ?? refreshToken;
        
        await _saveTokens(
          data['access_token'],
          newRefreshToken,
          data['expires_in'],
        );
      } else {
        throw Exception('Error refreshing token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ERROR] Error refreshing token: $e');
      throw e;
    }
  }
  
  Future<void> _saveTokens(String accessToken, String refreshToken, int expiresIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Calculate expiration date
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      
      // Store tokens
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_expiresAtKey, expiresAt.toIso8601String());
      
      // Update cached values
      _cachedToken = accessToken;
      _cachedTokenExpiry = expiresAt;
      
      debugPrint('[DEBUG] Tokens saved successfully. Expires at: $expiresAt');
    } catch (e) {
      debugPrint('[ERROR] Error saving tokens: $e');
      throw e;
    }
  }
  
  // Obtener token actual con caché optimizada
  Future<String?> getAccessToken() async {
    // Si ya tenemos un token en caché y no ha expirado
    if (_cachedToken != null && _cachedTokenExpiry != null) {
      // Si el token caduca en más de 5 minutos, usamos la caché
      if (DateTime.now().isBefore(_cachedTokenExpiry!.subtract(Duration(minutes: 5)))) {
        debugPrint('[DEBUG] Using cached Spotify token (valid for ${_cachedTokenExpiry!.difference(DateTime.now()).inMinutes} more minutes)');
        return _cachedToken;
      }
    }
    
    await _checkAuth();
    if (!isAuthenticated.value) {
      return null;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final expiresAtStr = prefs.getString(_expiresAtKey);
    
    if (token != null && expiresAtStr != null) {
      // Actualizar la caché
      _cachedToken = token;
      _cachedTokenExpiry = DateTime.parse(expiresAtStr);
      debugPrint('[DEBUG] Spotify token refreshed and cached');
    }
    
    return token;
  }
}


