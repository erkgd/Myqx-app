import 'package:flutter/material.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/core/services/auth_service_bff.dart';
import 'package:myqx_app/core/exceptions/api_exceptions.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/services/search_service.dart';
import 'package:myqx_app/core/services/spotify_search_service.dart';
import 'package:myqx_app/domain/models/user_model.dart';
import 'package:myqx_app/domain/models/auth_response_model.dart';
import 'package:myqx_app/presentation/providers/spotify_auth_provider.dart';
import 'package:myqx_app/core/services/spotify_profile_service.dart';

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
      isLoading.value = true;
      
      final token = await _secureStorage.getToken();
      debugPrint('[DEBUG] Iniciando estado de autenticación. Token existe: ${token != null}');
      
      if (token != null && token.isNotEmpty) {
        // Verificar token con el servidor
        debugPrint('[DEBUG] Verificando validez del token...');
        final isValid = await verifyToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('[DEBUG] Tiempo de espera agotado al verificar token');
            return false;
          },
        );
        
        if (isValid) {
          debugPrint('[DEBUG] Token válido, cargando datos de usuario');
          // Cargar datos del usuario almacenados localmente
          final userData = await _secureStorage.getUserData();
          if (userData != null && userData.isNotEmpty) {
            try {
              currentUser.value = User.fromJson(userData);
              isAuthenticated.value = true;
              debugPrint('[DEBUG] Usuario autenticado correctamente');
            } catch (e) {
              debugPrint('[DEBUG] Error al parsear datos de usuario: $e');
              await _cleanAuthState();
            }
          } else {
            debugPrint('[DEBUG] No se encontraron datos de usuario');
            await _cleanAuthState();
          }
        } else {
          debugPrint('[DEBUG] Token inválido, limpiando estado');
          await _cleanAuthState();
        }
      } else {
        debugPrint('[DEBUG] No hay token de autenticación');
        await _cleanAuthState();
      }
    } catch (e) {
      debugPrint('[DEBUG] Error en _initAuthState: $e');
      await _cleanAuthState();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Método auxiliar para limpiar el estado de autenticación
  Future<void> _cleanAuthState() async {
    try {
      await _secureStorage.clearAuthData();
    } catch (e) {
      debugPrint('[DEBUG] Error al limpiar datos de autenticación: $e');
    } finally {
      isAuthenticated.value = false;
      currentUser.value = null;
    }
  }
  /// Método público para forzar la limpieza de todo el estado de autenticación
  /// Se usa como último recurso cuando hay problemas con la sesión
  Future<void> forceCleanAuthState() async {
    try {
      debugPrint('[DEBUG] Forzando limpieza completa del estado de autenticación');
      
      // 1. Limpiar todo el almacenamiento seguro
      await _secureStorage.clearAuthData();
      
      // 2. Limpiar tokens de Spotify
      try {
        await _spotifyAuthProvider.clearAuthData();
        await _spotifyAuthService.logout();
      } catch (e) {
        debugPrint('[DEBUG] Error al limpiar datos de Spotify: $e');
        // Continuamos con el proceso aunque falle esto
      }
      
      // 3. Limpiar cachés de búsqueda y calificaciones
      try {
        // Acceder directamente a los servicios ya que están importados
        final spotifySearchService = SpotifySearchService();
        spotifySearchService.clearCache();
        debugPrint('[DEBUG] Caché de búsqueda de Spotify limpiada');
        
        // Limpiar caché de calificaciones
        final ratingService = SearchService();
        ratingService.clearRatingsCache();
        debugPrint('[DEBUG] Caché de calificaciones limpiada');
      } catch (e) {
        debugPrint('[DEBUG] Error al limpiar cachés: $e');
        // Continuamos con el proceso aunque falle esto
      }
      
      // 4. Resetear el estado observable
      currentUser.value = null;
      isAuthenticated.value = false;
      errorMessage.value = null;
      
      debugPrint('[DEBUG] Limpieza forzada completada con éxito');
    } catch (e) {
      debugPrint('[DEBUG] Error durante la limpieza forzada: $e');
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

      debugPrint('[DEBUG] Iniciando proceso de login con Spotify');

      // Limpiar cualquier estado anterior para evitar conflictos
      await _secureStorage.clearAuthData();
      isAuthenticated.value = false;
      currentUser.value = null;

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

      // 3. Obtener datos del perfil del usuario desde Spotify
      final spotifyUser = _spotifyAuthProvider.currentUser;
      if (spotifyUser == null) {
        errorMessage.value = 'No se pudo obtener los datos del usuario de Spotify';
        return false;
      }

      // 4. Enviar datos al BFF
      // Log para depurar los datos enviados al BFF
      debugPrint('[DEBUG] Enviando datos al BFF: spotifyToken=$spotifyToken, username=${spotifyUser.displayName}, profilePhoto=${spotifyUser.imageUrl}, spotifyId=${spotifyUser.id}');

      final response = await _apiClient.post(
        '/auth/spotify',
        body: {
          'spotifyToken': spotifyToken, // Cambiado de spotify_token a spotifyToken
          'username': spotifyUser.displayName,
          'profilePhoto': spotifyUser.imageUrl, // Cambiado de profile_image a profilePhoto
          'spotifyId': spotifyUser.id, // Añadido el ID de Spotify
          'email': spotifyUser.email
        },
        requiresAuth: false,
      );

      // Log para depurar la respuesta del BFF
      debugPrint('[DEBUG] Respuesta del BFF: ${response.toString()}');
      
      // 5. Procesar respuesta del BFF
      if (response['token'] != null) {
        // Guardar el nuevo token
        await _secureStorage.saveToken(response['token']);        
        if (response['user'] != null) {
          try {
            final user = User.fromSpotifyBff(response['user']);
            await _secureStorage.saveUserData(user.toJson());
            await _secureStorage.saveUserId(user.id); // Guardar el ID de usuario
            currentUser.value = user;
            debugPrint('[DEBUG] Datos de usuario guardados correctamente');
          } catch (e) {
            debugPrint('[DEBUG] Error al guardar datos de usuario: $e');
            // Continuar porque tenemos el token, que es lo crítico
          }
        }

        // Actualizar estado de autenticación explícitamente
        isAuthenticated.value = true;

        // Forzar notificación a todos los listeners inmediatamente
        notifyListeners();

        debugPrint('[DEBUG] Login exitoso');
        return true;
      } else {
        errorMessage.value = 'Respuesta del servidor inválida';
        return false;
      }
    } catch (e) {
      errorMessage.value =
          'Error al procesar autenticación con el servidor: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
      // Forzar una notificación adicional al terminar
      notifyListeners();
    }
  }
  
  /// Cierra la sesión del usuario
  Future<bool> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      debugPrint('[DEBUG] Iniciando proceso de logout...');
      await SpotifyProfileService().clear();
      // 1. Desconectar Spotify si está conectado (con mejor manejo de errores)
      try {
        debugPrint('[DEBUG] Desconectando Spotify...');
        await _spotifyAuthProvider.logout().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('[DEBUG] Tiempo de espera agotado al desconectar Spotify');
            return;
          },
        );
      } catch (e) {
        debugPrint('[DEBUG] Error al desconectar Spotify: $e');
        // Continuamos con el proceso de logout
      }
      
      // 2. Limpiar datos locales - CRÍTICO
      debugPrint('[DEBUG] Eliminando datos locales...');
      await _secureStorage.clearAuthData(); // Usar clearAuthData en lugar de métodos separados
      
      // 3. Intentar notificar al servidor sobre el logout (opcional)
      try {
        debugPrint('[DEBUG] Notificando al servidor sobre logout...');
        await _apiClient.post('/auth/logout', requiresAuth: false).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('[DEBUG] Tiempo de espera agotado al notificar al servidor');
            return;
          },
        );
      } catch (e) {
        debugPrint('[DEBUG] Error al notificar al servidor sobre logout: $e');
        // Ignorar errores del servidor al hacer logout
      }
      
      // 4. Al final, cuando todo el proceso de limpieza ha terminado, 
      // actualizamos el estado observable
      currentUser.value = null;
      isAuthenticated.value = false;
      
      debugPrint('[DEBUG] Logout completado con éxito');
      return true;
    } catch (e) {
      debugPrint('[DEBUG] Error general durante el logout: $e');
      errorMessage.value = 'Error al cerrar sesión: ${e.toString()}';
      
      // Incluso si hay un error, intentamos restablecer el estado a no autenticado
      try {
        await _secureStorage.clearAuthData();
        isAuthenticated.value = false;
        currentUser.value = null;
      } catch (_) {}
      
      return false;
    } finally {
      isLoading.value = false;
      notifyListeners(); // Asegurarnos de notificar a todos los listeners
    }
  }
  
  /// Verifica si un token almacenado es válido
  Future<bool> verifyToken() async {
    try {
      debugPrint('[DEBUG] Verificando validez del token...');
      
      // Verificar si hay un token almacenado
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('[DEBUG] No hay token almacenado para verificar');
        return false;
      }
      
      // Intentar verificar el token con el servidor
      try {
        final response = await _apiClient.post(
          '/auth/verify',
          requiresAuth: true,
        ).timeout(const Duration(seconds: 3));
        
        final isValid = response['valid'] == true;
        debugPrint('[DEBUG] Verificación de token: ${isValid ? "Válido" : "No válido"}');
        
        if (isValid && !isAuthenticated.value) {
          // Si el token es válido pero no estamos autenticados, actualizar el estado
          debugPrint('[DEBUG] Token válido pero estado no autenticado, actualizando...');
          isAuthenticated.value = true;
          
          // Intentar cargar los datos del usuario si no están disponibles
          if (currentUser.value == null) {
            try {
              final userResponse = await _apiClient.get('/auth/me');
              if (userResponse['user'] != null) {
                final user = User.fromMap(userResponse['user']);
                await _secureStorage.saveUserData(user.toJson());
                currentUser.value = user;
                debugPrint('[DEBUG] Datos de usuario cargados correctamente');
              }
            } catch (e) {
              debugPrint('[DEBUG] Error al cargar datos del usuario: $e');
              // No marcamos como error crítico, ya que el token sí es válido
            }
          }
        }
        
        return isValid;
      } catch (e) {
        debugPrint('[DEBUG] Error al verificar token: $e');
        return false;
      }
    } catch (e) {
      debugPrint('[DEBUG] Error general al verificar token: $e');
      return false;
    }
  }
  
  /// Verifica si hay un token de autenticación almacenado
  Future<bool> hasStoredToken() async {
    try {
      final token = await _secureStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('[DEBUG] Error al verificar token almacenado: $e');
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