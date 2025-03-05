import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyAuthService {
  // Reemplaza estos valores con tu configuración de Spotify Developer
  static const String _clientId = 'YOUR_CLIENT_ID';
  static const String _redirectUri = 'myqx://callback';
  
  // Scope necesario para acceder a datos del usuario y de música
  static const String _scope = 'user-read-email user-read-private user-top-read user-library-read';
  
  // Claves para almacenamiento local
  static const String _accessTokenKey = 'spotify_access_token';
  static const String _refreshTokenKey = 'spotify_refresh_token';
  static const String _expiresAtKey = 'spotify_expires_at';
  
  // URLs de Spotify
  static const String _authUrl = 'https://accounts.spotify.com/authorize';
  static const String _tokenUrl = 'https://accounts.spotify.com/api/token';
  static const String _apiUrl = 'https://api.spotify.com/v1';
  
  // Estado de autenticación
  ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  
  // Singleton pattern
  static final SpotifyAuthService _instance = SpotifyAuthService._internal();
  
  factory SpotifyAuthService() {
    return _instance;
  }
  
  SpotifyAuthService._internal() {
    _checkAuth();
  }
  
  // Verificar si ya está autenticado al inicializar
  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final expiresAtStr = prefs.getString(_expiresAtKey);
    
    if (accessToken != null && expiresAtStr != null) {
      final expiresAt = DateTime.parse(expiresAtStr);
      if (expiresAt.isAfter(DateTime.now())) {
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
        }
      }
    }
  }
  
  // Generar estado aleatorio para seguridad
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  // Iniciar sesión con Spotify
  Future<bool> login() async {
    try {
      isLoading.value = true;
      
      final state = _generateRandomString(16);
      final queryParameters = {
        'client_id': _clientId,
        'response_type': 'code',
        'redirect_uri': _redirectUri,
        'state': state,
        'scope': _scope,
        'show_dialog': 'true'
      };
      
      final authorizeUrl = Uri.parse('$_authUrl?${Uri(queryParameters: queryParameters).query}');
      
      // Iniciar flujo de autenticación - Actualizado para flutter_web_auth_2
      final result = await FlutterWebAuth2.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: 'myqx',
      );
      
      // Extraer código de autorización
      final uri = Uri.parse(result);
      final receivedState = uri.queryParameters['state'];
      if (receivedState != state) {
        throw Exception('Estado inválido, posible ataque CSRF');
      }
      
      final code = uri.queryParameters['code'];
      if (code == null) {
        throw Exception('No se recibió código de autorización');
      }
      
      // Obtener token de acceso
      await _getAccessToken(code);
      isAuthenticated.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      debugPrint('Error en la autenticación de Spotify: $e');
      return false;
    }
  }
  
  // Obtener token de acceso con código de autorización
  Future<void> _getAccessToken(String code) async {
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
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
      throw Exception('Error obteniendo token de acceso: ${response.body}');
    }
  }
  
  // Refrescar token de acceso
  Future<void> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveTokens(
        data['access_token'],
        data['refresh_token'] ?? refreshToken, // Usar el nuevo refresh_token si lo hay
        data['expires_in'],
      );
    } else {
      throw Exception('Error refrescando token: ${response.body}');
    }
  }
  
  // Guardar tokens en almacenamiento local
  Future<void> _saveTokens(String accessToken, String refreshToken, int expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_expiresAtKey, expiresAt.toIso8601String()),
    ]);
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_expiresAtKey),
    ]);
    isAuthenticated.value = false;
  }
  
  // Obtener token actual
  Future<String?> getCurrentToken() async {
    await _checkAuth();
    if (!isAuthenticated.value) {
      return null;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  
  // Hacer peticiones a la API de Spotify
  Future<Map<String, dynamic>> getSpotifyData(String endpoint) async {
    final token = await getCurrentToken();
    if (token == null) {
      throw Exception('No hay sesión activa');
    }
    
    final response = await http.get(
      Uri.parse('$_apiUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expirado, intentar refrescar
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken != null) {
        await _refreshAccessToken(refreshToken);
        return getSpotifyData(endpoint); // Reintentar con nuevo token
      }
      throw Exception('Sesión expirada');
    } else {
      throw Exception('Error en petición a Spotify: ${response.body}');
    }
  }
  
  // Obtener información del perfil
  Future<Map<String, dynamic>> getUserProfile() async {
    return getSpotifyData('me');
  }
  
  // Obtener los álbumes favoritos
  Future<List<dynamic>> getTopAlbums() async {
    final data = await getSpotifyData('me/top/tracks?limit=5');
    return data['items'] ?? [];
  }
}