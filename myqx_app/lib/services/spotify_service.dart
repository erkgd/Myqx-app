/*import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/spotify_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class SpotifyService {
  static const String _clientId = SpotifyConstants.clientId;
  static const String _clientSecret = SpotifyConstants.clientSecret;
  static const String _redirectUri = SpotifyConstants.redirectUri;
  
  static const String _authUrl = SpotifyConstants.authUrl;
  static const String _tokenUrl = SpotifyConstants.tokenUrl;
  static const String _apiUrl = SpotifyConstants.apiUrl;
  
  String? _accessToken;
  
  // Inicializa el servicio y verifica si ya hay un token almacenado
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('spotify_access_token');
  }
  
  // Autentica al usuario con Spotify
  Future<bool> authenticate() async {
    try {
      // Definir los scopes que necesitamos
      final String scopes = 'user-library-read user-library-modify';
      
      // Construir la URL de autorización
      final String authUrl = '$_authUrl?client_id=$_clientId&response_type=code&redirect_uri=$_redirectUri&scope=$scopes';
      
      // Abrir el navegador para autenticación
      final result = await FlutterWebAuth.authenticate(
        url: authUrl,
        callbackUrlScheme: 'myqx',
      );
      
      // Extraer el código de autorización
      final code = Uri.parse(result).queryParameters['code'];
      
      // Intercambiar el código por un token de acceso
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:$_clientSecret')),
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
        },
      );
      
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      
      // Guardar el token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('spotify_access_token', _accessToken!);
      
      return true;
    } catch (e) {
      debugPrint('Error en autenticación: $e');
      return false;
    }
  }
  
  // Verificar si una canción está en "Me gusta"
  Future<bool> isSongLiked(String songId) async {
    if (_accessToken == null) {
      await authenticate();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/me/tracks/contains?ids=$songId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.isNotEmpty && data[0] == true;
      } else {
        throw Exception('Error al verificar estado: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al verificar si la canción está en "Me gusta": $e');
      return false;
    }
  }
  
  // Añadir canción a "Me gusta"
  Future<void> likeSong(String songId) async {
    if (_accessToken == null) {
      await authenticate();
    }
    
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/me/tracks'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ids': [songId],
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al añadir canción: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al añadir canción a "Me gusta": $e');
      throw e;
    }
  }
  
  // Quitar canción de "Me gusta"
  Future<void> unlikeSong(String songId) async {
    if (_accessToken == null) {
      await authenticate();
    }
    
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/me/tracks'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ids': [songId],
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Error al quitar canción: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al quitar canción de "Me gusta": $e');
      throw e;
    }
  }
}
*/