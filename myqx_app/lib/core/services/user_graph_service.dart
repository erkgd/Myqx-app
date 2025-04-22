import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/exceptions/api_exceptions.dart';
import 'package:myqx_app/core/services/auth_service_bff.dart';

class UserGraphService {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final AuthServiceBff _authService;
  
  UserGraphService({
    ApiClient? apiClient, 
    SecureStorage? secureStorage,
    AuthServiceBff? authService,
  }) 
      : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorage(),
        _authService = authService ?? AuthServiceBff();
  /// Verifica si hay un token de autenticación disponible
  Future<bool> _isAuthenticated() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
    /// Intenta ejecutar una operación con autenticación y refresca el token si es necesario
  Future<T> _executeWithTokenRefresh<T>(Future<T> Function() operation) async {
    try {
      // Verificar autenticación antes de hacer la petición
      if (!await _isAuthenticated()) {
        throw AuthException('Authentication required. Please log in to access this feature.');
      }
      
      try {
        // Intentar ejecutar la operación
        return await operation();
      } on ApiException catch (e) {
        // Si es un error de autorización (401), intentamos refrescar el token
        if (e.statusCode == 401) {
          debugPrint('Token expirado, intentando refrescar...');
          final refreshed = await _authService.refreshToken();
          if (refreshed) {
            debugPrint('Token refrescado con éxito, reintentando operación...');
            // Si se refrescó el token correctamente, reintentamos la operación
            return await operation();
          } else {
            debugPrint('No se pudo refrescar el token');
            throw AuthException('Session expired. Please log in again.', statusCode: 401);
          }
        }
        // Si no es 401, propagamos la excepción original
        rethrow;
      }
    } on AuthException {
      rethrow; // Propagar excepciones de autenticación
    } catch (e) {
      throw ApiException('Operation failed: ${e.toString()}', statusCode: e is ApiException ? e.statusCode : null);
    }
  }

  Future<Map<String, dynamic>> fetchFollowingNetwork() async {
    try {
      return await _executeWithTokenRefresh(() async {
        // Obtener el ID del usuario del almacenamiento seguro
        final userId = await _secureStorage.getUserId();
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID not found. Please log in again.');
        }

        // Log para depurar la URL
        debugPrint('[DEBUG] Fetching following network for userId: $userId');
        final url = '/$userId/following_network/';
        debugPrint('[DEBUG] URL: $url');

        // Usar el ID del usuario en la URL
        final response = await _apiClient.get(url);
        debugPrint('[DEBUG] Response: ${response.toString()}');
        return response;
      });
    } catch (e) {
      debugPrint('[DEBUG] Error in fetchFollowingNetwork: ${e.toString()}');
      throw Exception('Failed to load following network: ${e.toString()}');
    }
  }

  Future<void> sendDataToBFF(Map<String, dynamic> data) async {
    try {
      await _executeWithTokenRefresh(() async {
        // Obtener el ID del usuario del almacenamiento seguro
        final userId = await _secureStorage.getUserId();
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID not found. Please log in again.');
        }

        // Log para depurar la URL y los datos
        debugPrint('[DEBUG] Sending data to BFF for userId: $userId');
        final url = '/$userId/following_network/';
        debugPrint('[DEBUG] URL: $url');
        debugPrint('[DEBUG] Data: ${data.toString()}');

        // Usar el ID del usuario en la URL
        await _apiClient.post(url, body: data);
        debugPrint('[DEBUG] Data sent successfully');
      });
    } catch (e) {
      debugPrint('[DEBUG] Error in sendDataToBFF: ${e.toString()}');
      throw Exception('Failed to send data to BFF: ${e.toString()}');
    }
  }
}