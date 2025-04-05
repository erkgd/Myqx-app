import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/exceptions/api_exceptions.dart';
import 'package:myqx_app/domain/models/user_model.dart';
import 'package:myqx_app/domain/models/auth_response_model.dart';

class AuthServiceBff {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  
  // Notificadores para cambios en el estado de autenticación
  final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  // Constructor que permite inyección de dependencias para testeo
  AuthServiceBff({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
  }) : 
    _apiClient = apiClient ?? ApiClient(),
    _secureStorage = secureStorage ?? SecureStorage() {
    // Cargar el estado de autenticación al inicializar
    _loadAuthenticationState();
  }

  // Método para inicializar y cargar el estado de autenticación
  Future<void> _loadAuthenticationState() async {
    final isAuthenticatedResult = await _secureStorage.isAuthenticated();
    isAuthenticated.value = isAuthenticatedResult;
    
    if (isAuthenticatedResult) {
      final userData = await _secureStorage.getUserData();
      if (userData != null) {
        try {
          currentUser.value = User.fromJson(userData);
        } catch (e) {
          // Si hay algún error al decodificar el usuario, consideramos que no está autenticado
          await logout();
        }
      }
    }
  }

  // Método para iniciar sesión
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth',
        body: {'username': username, 'password': password},
        requiresAuth: false,
      );
      
      // Verificamos que la respuesta tenga la estructura esperada
      if (response['token'] != null && response['user'] != null) {
        final authResponse = AuthResponse.fromMap(response);
        
        // Guardamos los datos en almacenamiento seguro
        await _secureStorage.saveToken(authResponse.token);
        if (authResponse.refreshToken != null) {
          await _secureStorage.saveRefreshToken(authResponse.refreshToken!);
        }
        await _secureStorage.saveUserId(authResponse.user.id ?? '');
        await _secureStorage.saveUserData(json.encode(authResponse.user.toMap()));
        
        // Actualizamos el estado de autenticación
        isAuthenticated.value = true;
        currentUser.value = authResponse.user;
        
        return authResponse;
      } else {
        throw ApiException('Formato de respuesta inválido');
      }
    } on ApiException {
      // Propagamos las excepciones específicas de la API
      rethrow;
    } catch (e) {
      // Para otros errores, creamos una excepción genérica
      throw ApiException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      // Intentamos notificar al servidor sobre el cierre de sesión
      // Esto no es crítico, así que capturamos cualquier error
      try {
        await _apiClient.post('/auth/logout');
      } catch (_) {
        // Ignoramos errores al hacer logout en el servidor
      }
      
      // Limpiamos los datos localmente
      await _secureStorage.clearAuthData();
      
      // Actualizamos el estado de autenticación
      isAuthenticated.value = false;
      currentUser.value = null;
    } catch (e) {
      throw ApiException('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // Método para verificar si el token actual es válido
  Future<bool> verifyToken() async {
    try {
      final response = await _apiClient.post('/auth/verify');
      return response['valid'] == true;
    } catch (e) {
      // Si hay algún error, consideramos que el token no es válido
      return false;
    }
  }

  // Método para actualizar el token usando refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _apiClient.post(
        '/auth/token/refresh',
        body: {'refresh': refreshToken},
        requiresAuth: false,
      );
      
      if (response['token'] != null) {
        await _secureStorage.saveToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Método para cambiar la contraseña
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final userId = await _secureStorage.getUserId();
      if (userId == null) return false;
      
      await _apiClient.post(
        '/auth/change-password',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para solicitar restablecimiento de contraseña
  Future<bool> requestPasswordReset(String email) async {
    try {
      await _apiClient.post(
        '/auth/password-reset',
        body: {'email': email},
        requiresAuth: false,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para testear la conexión con el servicio de autenticación
  Future<bool> testConnection() async {
    try {
      final response = await _apiClient.get('/auth/test', requiresAuth: false);
      return response['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }
}