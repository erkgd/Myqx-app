import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/exceptions/api_exceptions.dart';

class ApiClient {
  final http.Client _httpClient;
  final SecureStorage _secureStorage;

  ApiClient({
    http.Client? httpClient,
    SecureStorage? secureStorage,
  }) : 
    _httpClient = httpClient ?? http.Client(),
    _secureStorage = secureStorage ?? SecureStorage();

  // URLs base para diferentes entornos
  static const String _baseUrlDev = 'http://10.0.2.2:8000/api'; // Para emulador Android
  static const String _baseUrlProd = 'https://api.myqx.com/api';
  
  // URL base según el entorno
  String get baseUrl => kReleaseMode ? _baseUrlProd : _baseUrlDev;
  // Headers por defecto para las peticiones
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        // Log del token JWT para depuración (mostrando solo los primeros y últimos caracteres por seguridad)
        if (token.length > 15) {
          debugPrint('[JWT] Enviando token: ${token.substring(0, 7)}...${token.substring(token.length - 7)}');
          // Log para ver cuando expira el token (si tiene el formato estándar JWT)
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final payload = json.decode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
              );
              if (payload['exp'] != null) {
                final expDate = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
                final now = DateTime.now();
                final diff = expDate.difference(now);
                debugPrint('[JWT] Token expira en: ${diff.inMinutes} minutos (${expDate.toIso8601String()})');
              }
            }
          } catch (e) {
            debugPrint('[JWT] No se pudo decodificar el payload del token');
          }
        } else {
          debugPrint('[JWT] Enviando token (formato inválido o incompleto): $token');
        }
      } else {
        debugPrint('[DEBUG] ADVERTENCIA: Se solicitó una petición autenticada pero no hay token disponible');
        // Si se requiere autenticación pero no hay token,
        // podría lanzar una excepción aquí, pero es mejor dejar que
        // el servidor responda con 401 para un mejor manejo del flujo
      }
    }

    return headers;
  }
  // Método GET
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      
      // Log de la petición
      debugPrint('[HTTP GET] $baseUrl$endpoint');
      debugPrint('[HTTP Headers] $headers');
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      // Log de la respuesta
      debugPrint('[HTTP Response] Status: ${response.statusCode}, URL: $baseUrl$endpoint');
      if (response.statusCode == 401) {
        debugPrint('[HTTP 401] Respuesta completa: ${response.body}');
        debugPrint('[HTTP 401] Headers de la respuesta: ${response.headers}');
      }

      return _handleResponse(response);
    } on SocketException {
      debugPrint('[HTTP ERROR] No hay conexión a Internet para $baseUrl$endpoint');
      throw NetworkException('No hay conexión a Internet');
    } on http.ClientException {
      debugPrint('[HTTP ERROR] Error de conexión con el servidor $baseUrl$endpoint');
      throw NetworkException('Error en la conexión con el servidor');
    } catch (e) {
      debugPrint('[HTTP ERROR] Error inesperado para $baseUrl$endpoint: ${e.toString()}');
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  // Método POST
  Future<dynamic> post(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a Internet');
    } on http.ClientException {
      throw NetworkException('Error en la conexión con el servidor');
    } catch (e) {
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  // Método PUT
  Future<dynamic> put(String endpoint, {dynamic body, bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _httpClient.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a Internet');
    } on http.ClientException {
      throw NetworkException('Error en la conexión con el servidor');
    } catch (e) {
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  // Método DELETE
  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a Internet');
    } on http.ClientException {
      throw NetworkException('Error en la conexión con el servidor');
    } catch (e) {
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  // Manejador de respuestas
  dynamic _handleResponse(http.Response response) {
    // Log detallado de la respuesta HTTP
    debugPrint('[HTTP] ${response.request?.method} ${response.request?.url.path} - Status: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Verificamos si hay un body para decodificar
      if (response.body.isEmpty) {
        debugPrint('[HTTP] Respuesta exitosa sin cuerpo');
        return {};
      }
      debugPrint('[HTTP] Respuesta exitosa: ${response.body.length > 500 ? '${response.body.substring(0, 100)}... (truncado)' : response.body}');
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      debugPrint('[HTTP] ERROR 401 UNAUTHORIZED - URL: ${response.request?.url}');
      debugPrint('[HTTP] Cuerpo de la respuesta 401: ${response.body}');
      debugPrint('[HTTP] Headers enviados: ${response.request?.headers}');
      throw UnauthorizedException('No autorizado. Por favor inicia sesión nuevamente.', 
        data: response.body.isNotEmpty ? json.decode(response.body) : null);
    } else if (response.statusCode == 403) {
      debugPrint('[HTTP] ERROR 403 FORBIDDEN: ${response.body}');
      throw ForbiddenException('No tienes permisos para realizar esta acción.');
    } else if (response.statusCode == 404) {
      debugPrint('[HTTP] ERROR 404 NOT FOUND: ${response.request?.url}');
      throw NotFoundException('El recurso solicitado no existe.');
    } else if (response.statusCode >= 500) {
      debugPrint('[HTTP] ERROR ${response.statusCode} SERVER ERROR: ${response.body}');
      throw ServerException('Error en el servidor. Inténtalo más tarde.');
    } else {
      debugPrint('[HTTP] ERROR ${response.statusCode}: ${response.body}');
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? errorData['detail'] ?? 'Error en la solicitud';
        throw ApiException(errorMessage, statusCode: response.statusCode, data: errorData);
      } catch (e) {
        throw ApiException('Error en la solicitud: ${response.statusCode}', statusCode: response.statusCode);
      }
    }
  }
}