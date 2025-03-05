import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/constants/spotify_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show SystemNavigator;


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
  static const String _apiUrl = SpotifyConstants.apiUrl;
  
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
  
  Future<bool> _isSpotifyInstalled() async {
    final spotifyUri = Uri.parse('spotify:');
    
    try {
      // Verificamos si podemos lanzar la URI de Spotify
      return await canLaunchUrl(spotifyUri);
    } catch (e) {
      debugPrint('Error checking if Spotify is installed: $e');
      return false;
    }
  }
  
  // Iniciar sesión con Spotify con verificación previa
  Future<bool> login() async {
  try {
    isLoading.value = true;
    debugPrint('[DEBUG] Iniciando proceso de login con Spotify...');

    // Verificar si Spotify está instalado (opcional)
    final hasSpotify = await _isSpotifyInstalled();
    if (!hasSpotify) {
      debugPrint('[DEBUG] Spotify no está instalado. Usando autenticación web.');
    }

    // Generar estado para seguridad contra ataques CSRF
    final state = _generateRandomString(16);
    final queryParameters = {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'state': state,
      'scope': _scope,
      'show_dialog': 'true',
    };

    final authorizeUrl = Uri.parse('$_authUrl?${Uri(queryParameters: queryParameters).query}');
    debugPrint('[DEBUG] URL de autenticación generada: $authorizeUrl');

    String result;

    try {
      // Iniciar la autenticación web
      result = await FlutterWebAuth2.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: 'myqx', // Esquema de callback
      );
      debugPrint('[DEBUG] Autenticación completada, procesando respuesta...');
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        debugPrint('[DEBUG] Usuario canceló el proceso de autenticación.');
      } else {
        debugPrint('[DEBUG] Error en autenticación: ${e.message}');
      }
      return false;
    }

    // Procesar la respuesta de autenticación
    final uri = Uri.parse(result);
    final receivedState = uri.queryParameters['state'];
    if (receivedState != state) {
      debugPrint('[DEBUG] Estado inválido, posible ataque CSRF');
      return false;
    }

    // Obtener el código de autorización
    final code = uri.queryParameters['code'];
    if (code == null) {
      debugPrint('[DEBUG] No se recibió código de autorización');
      return false;
    }

    // Obtener el token de acceso usando el código de autorización
    debugPrint('[DEBUG] Código de autorización recibido. Obteniendo token...');
    await _getAccessToken(code);
    isAuthenticated.value = true;

    debugPrint('[DEBUG] Login exitoso');
    return true;
  } catch (e) {
    debugPrint('[DEBUG] Error inesperado en el proceso de login: $e');
    return false;
  } finally {
    isLoading.value = false;
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
        'client_secret': SpotifyConstants.clientSecret, // Añadido client_secret
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
      debugPrint('Error de Spotify: ${response.body}');
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
        'client_secret': SpotifyConstants.clientSecret, // Añadido client_secret
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
  
  // Cerrar sesión de manera segura
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_expiresAtKey),
      ]);
      
      // Opcional: Si quieres revocar el token en Spotify para mayor seguridad
      // pero no es estrictamente necesario
      final token = await getCurrentToken();
      if (token != null) {
        try {
          await http.post(
            Uri.parse('https://accounts.spotify.com/api/token/revoke'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:${SpotifyConstants.clientSecret}')),
            },
            body: {
              'token': token,
              'token_type_hint': 'access_token',
            },
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          // Ignoramos errores aquí, no afecta al logout local
          debugPrint('Error al revocar token: $e');
        }
      }
    } catch (e) {
      debugPrint('Error durante logout: $e');
    } finally {
      // Asegurar que el estado de autenticación se actualice
      isAuthenticated.value = false;
      isLoading.value = false;
    }
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
  
  
}


