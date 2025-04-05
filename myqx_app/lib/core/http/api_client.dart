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
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Método GET
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _httpClient.get(
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Verificamos si hay un body para decodificar
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('No autorizado. Por favor inicia sesión nuevamente.');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('No tienes permisos para realizar esta acción.');
    } else if (response.statusCode == 404) {
      throw NotFoundException('El recurso solicitado no existe.');
    } else if (response.statusCode >= 500) {
      throw ServerException('Error en el servidor. Inténtalo más tarde.');
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Error en la solicitud';
        throw ApiException(errorMessage, statusCode: response.statusCode);
      } catch (e) {
        throw ApiException('Error en la solicitud: ${response.statusCode}');
      }
    }
  }
}