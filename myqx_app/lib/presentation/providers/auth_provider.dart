import 'package:flutter/material.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/core/services/auth_service_bff.dart';
import 'package:myqx_app/core/exceptions/api_exceptions.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/domain/models/user_model.dart';
import 'package:myqx_app/domain/models/auth_response_model.dart';
import 'package:myqx_app/presentation/providers/spotify_auth_provider.dart';

/// Servicio unificado para gestionar la autenticación con APIs y Spotify
class AuthService extends ChangeNotifier {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  // Servicios dependientes
  final SpotifyAuthService _spotifyAuthService;
  final AuthServiceBff _authServiceBff;
  final SecureStorage _secureStorage;
  final ApiClient _apiClient;
  late final SpotifyAuthProvider _spotifyAuthProvider;
  
  // Estado observable para la autenticación
  final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  
  AuthService._internal() : 
    _spotifyAuthService = SpotifyAuthService(),
    _authServiceBff = AuthServiceBff(),
    _secureStorage = SecureStorage(),
    _apiClient = ApiClient() {
    // Inicializar provider de Spotify
    _spotifyAuthProvider = SpotifyAuthProvider(authService: _spotifyAuthService);
    
    // Inicializar estado de autenticación al crear el servicio
    _initAuthState();
    
    // Añadir listeners para notificar cambios
    isAuthenticated.addListener(_notifyAuthChange);
    currentUser.addListener(_notifyAuthChange);
    isLoading.addListener(_notifyAuthChange);
    errorMessage.addListener(_notifyAuthChange);
  }
  
  // Getter para el SpotifyAuthProvider
  SpotifyAuthProvider get spotifyAuthProvider => _spotifyAuthProvider;
  
  // Método para notificar cambios a los listeners
  void _notifyAuthChange() {
    notifyListeners();
  }

  /// Inicializa el estado de autenticación desde almacenamiento local
  Future<void> _initAuthState() async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        // Verificar token con el servidor
        final isValid = await verifyToken();
        
        if (isValid) {
          // Cargar datos del usuario almacenados localmente
          final userData = await _secureStorage.getUserData();
          if (userData != null && userData.isNotEmpty) {
            currentUser.value = User.fromJson(userData);
          }
          isAuthenticated.value = true;
        } else {
          // Token no válido, limpiar almacenamiento
          await _secureStorage.deleteToken();
          await _secureStorage.deleteUserData();
          isAuthenticated.value = false;
          currentUser.value = null;
        }
      } else {
        isAuthenticated.value = false;
        currentUser.value = null;
      }
    } catch (e) {
      isAuthenticated.value = false;
      currentUser.value = null;
    }
  }
  
  /// Inicia sesión con credenciales de usuario
  Future<AuthResponse?> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      final response = await _apiClient.post(
        '/auth/login',
        body: {
          'username': username,
          'password': password,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response);
      
      // Guardar token y datos de usuario
      await _secureStorage.saveToken(authResponse.token);
      
      if (authResponse.user != null) {
        await _secureStorage.saveUserData(authResponse.user!.toJson());
        currentUser.value = authResponse.user;
      }
      
      isAuthenticated.value = true;
      return authResponse;
    } catch (e) {
      errorMessage.value = 'Error en inicio de sesión: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Inicia sesión completo con Spotify (auth de Spotify + validación en BFF)
  Future<bool> loginWithSpotify() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      // 1. Autenticar con Spotify
      final spotifySuccess = await _spotifyAuthProvider.login();
      if (!spotifySuccess) {
        errorMessage.value = _spotifyAuthProvider.errorMessage ?? 
                             'Error al autenticar con Spotify';
        return false;
      }
      
      // 2. Obtener token y enviarlo al BFF
      final spotifyToken = _spotifyAuthProvider.accessToken;
      if (spotifyToken == null) {
        errorMessage.value = 'No se pudo obtener el token de Spotify';
        return false;
      }
      
      // 3. Autenticar con el BFF usando el token de Spotify
      try {
        final response = await _apiClient.post(
          '/auth/spotify',
          body: {'spotify_token': spotifyToken},
          requiresAuth: false,
        );
        
        // 4. Procesar respuesta del BFF
        if (response['token'] != null) {
          await _secureStorage.saveToken(response['token']);
          
          if (response['user'] != null) {
            final user = User.fromMap(response['user']);
            await _secureStorage.saveUserData(user.toJson());
            currentUser.value = user;
          }
          
          isAuthenticated.value = true;
          return true;
        } else {
          errorMessage.value = 'Respuesta del servidor inválida';
          return false;
        }
      } catch (e) {
        errorMessage.value = 'Error al procesar autenticación con el servidor: ${e.toString()}';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error en el proceso de login: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      // Intentar notificar al servidor sobre el logout
      try {
        await _apiClient.post('/auth/logout');
      } catch (_) {
        // Ignorar errores del servidor al hacer logout
      }
      
      // Desconectar Spotify si está conectado
      try {
        await _spotifyAuthProvider.logout();
      } catch (_) {
        // Ignorar errores al desconectar Spotify
      }
      
      // Limpiar datos locales
      await _secureStorage.deleteToken();
      await _secureStorage.deleteUserData();
      
      // Actualizar estado observable
      isAuthenticated.value = false;
      currentUser.value = null;
    } catch (e) {
      errorMessage.value = 'Error al cerrar sesión: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Verifica si el token actual es válido
  Future<bool> verifyToken() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) return false;
      
      final response = await _apiClient.get('/auth/verify');
      return response['valid'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Autentica con Spotify y envía los tokens al BFF
  Future<bool> authenticateWithSpotify() async {
    try {
      // 1. Autenticar con Spotify
      final spotifyLoginSuccess = await _spotifyAuthService.login();
      if (!spotifyLoginSuccess) {
        return false;
      }
      
      // 2. Obtener token de acceso
      final spotifyToken = await _spotifyAuthService.getAccessToken();
      if (spotifyToken == null || spotifyToken.isEmpty) {
        return false;
      }
      
      // 3. Enviar token al BFF
      final token = await _secureStorage.getToken();
      if (token == null || token.isEmpty) return false;
      
      final response = await _apiClient.post(
        '/auth/spotify/connect',
        body: {
          'spotify_token': spotifyToken,
        },
      );
      
      // 4. Actualizar información del usuario si es necesario
      if (response['user'] != null) {
        final updatedUser = User.fromJson(response['user']);
        await _secureStorage.saveUserData(updatedUser.toJson());
        currentUser.value = updatedUser;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Cambia la contraseña del usuario actual
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.post(
        '/auth/change-password',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Solicita restablecimiento de contraseña
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/auth/reset-password-request',
        body: {
          'email': email,
        },
      );
      
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Verifica si el usuario actual tiene una cuenta de Spotify conectada
  Future<bool> hasConnectedSpotifyAccount() async {
    try {
      final response = await _apiClient.get('/auth/spotify/status');
      return response['connected'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene el token de acceso de Spotify
  Future<String?> getSpotifyAccessToken() async {
    try {
      return await _spotifyAuthService.getAccessToken();
    } catch (e) {
      return null;
    }
  }
  
  /// Prueba la conexión con el servidor de autenticación
  Future<bool> testConnection() async {
    try {
      final response = await _apiClient.get('/health');
      return response['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }
  
  @override
  void dispose() {
    // Eliminar listeners para evitar memory leaks
    isAuthenticated.removeListener(_notifyAuthChange);
    currentUser.removeListener(_notifyAuthChange);
    isLoading.removeListener(_notifyAuthChange);
    errorMessage.removeListener(_notifyAuthChange);
    super.dispose();
  }
}