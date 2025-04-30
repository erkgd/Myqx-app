import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  // Claves para el almacenamiento
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  // Constructor que permite inyección de dependencias para pruebas
  SecureStorage({FlutterSecureStorage? storage}) 
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );
  // Métodos para token de autenticación
  Future<void> saveToken(String token) async {
    debugPrint('📦 SecureStorage: Guardando token de autenticación');
    try {
      await _storage.write(key: _tokenKey, value: token);
      debugPrint('✅ SecureStorage: Token guardado exitosamente');
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al guardar token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      debugPrint('🔍 SecureStorage: Token recuperado: ${token != null ? 'Presente (${token.length} caracteres)' : 'No encontrado'}');
      return token;
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al recuperar token: $e');
      return null;
    }
  }
  
  // Eliminar token de autenticación
  Future<void> deleteToken() async {
    debugPrint('🗑️ SecureStorage: Eliminando tokens de autenticación');
    try {
      // Eliminamos tanto el token de acceso como el refresh token
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      debugPrint('✅ SecureStorage: Tokens eliminados exitosamente');
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al eliminar tokens: $e');
      rethrow;
    }
  }
  // Métodos para refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    debugPrint('📦 SecureStorage: Guardando refresh token');
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      debugPrint('✅ SecureStorage: Refresh token guardado exitosamente');
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al guardar refresh token: $e');
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      debugPrint('🔍 SecureStorage: Refresh token recuperado: ${refreshToken != null ? 'Presente (${refreshToken.length} caracteres)' : 'No encontrado'}');
      return refreshToken;
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al recuperar refresh token: $e');
      return null;
    }
  }
  // Métodos para ID de usuario
  Future<void> saveUserId(String userId) async {
    debugPrint('🆔🆔🆔 SecureStorage: GUARDANDO USER ID: "$userId" 🆔🆔🆔');
    try {
      await _storage.write(key: _userIdKey, value: userId);
      debugPrint('✅✅✅ SecureStorage: ID DE USUARIO "$userId" GUARDADO EXITOSAMENTE ✅✅✅');
    } catch (e) {
      debugPrint('❌❌❌ SecureStorage: ERROR AL GUARDAR ID DE USUARIO "$userId": $e ❌❌❌');
      rethrow;
    }
  }
  Future<String?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      debugPrint('🔍🔍🔍 SecureStorage: ID DE USUARIO RECUPERADO: "${userId ?? 'NO ENCONTRADO'}" 🔍🔍🔍');
      return userId;
    } catch (e) {
      debugPrint('❌❌❌ SecureStorage: ERROR AL RECUPERAR ID DE USUARIO: $e ❌❌❌');
      return null;
    }
  }
  Future<void> deleteUserId() async {
    debugPrint('🗑️🗑️🗑️ SecureStorage: ELIMINANDO USER ID 🗑️🗑️🗑️');
    try {
      await _storage.delete(key: _userIdKey);
      debugPrint('✅✅✅ SecureStorage: ID DE USUARIO ELIMINADO EXITOSAMENTE ✅✅✅');
    } catch (e) {
      debugPrint('❌❌❌ SecureStorage: ERROR AL ELIMINAR ID DE USUARIO: $e ❌❌❌');
      rethrow;
    }
  }

  // Métodos para datos de usuario (como JSON string)
  Future<void> saveUserData(String userData) async {
    debugPrint('📦 SecureStorage: Guardando datos de usuario (${userData.length} caracteres)');
    try {
      await _storage.write(key: _userDataKey, value: userData);
      debugPrint('✅ SecureStorage: Datos de usuario guardados exitosamente');
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al guardar datos de usuario: $e');
      rethrow;
    }
  }

  Future<String?> getUserData() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      debugPrint('🔍 SecureStorage: Datos de usuario recuperados: ${userData != null ? 'Presente (${userData.length} caracteres)' : 'No encontrados'}');
      return userData;
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al recuperar datos de usuario: $e');
      return null;
    }
  }
  
  Future<void> deleteUserData() async {
    debugPrint('🗑️ SecureStorage: Eliminando datos de usuario');
    try {
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userDataKey);
      debugPrint('✅ SecureStorage: Datos de usuario eliminados exitosamente');
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al eliminar datos de usuario: $e');
      rethrow;
    }
  }
  // Método para limpiar todos los datos de autenticación
  Future<void> clearAuthData() async {
    debugPrint('🧹 SecureStorage: Limpiando todos los datos de autenticación');
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userDataKey);
      debugPrint('✅ SecureStorage: Todos los datos de autenticación eliminados exitosamente');
    } catch (e) {
      debugPrint('❌ SecureStorage: Error al limpiar datos de autenticación: $e');
      rethrow;
    }
  }

  // Método para verificar si hay un token guardado (usuario autenticado)
  Future<bool> isAuthenticated() async {
    debugPrint('🔐 SecureStorage: Verificando si el usuario está autenticado');
    final token = await getToken();
    final isAuth = token != null && token.isNotEmpty;
    debugPrint('🔐 SecureStorage: Estado de autenticación: ${isAuth ? 'Autenticado' : 'No autenticado'}');
    return isAuth;
  }
}