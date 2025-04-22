import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Clase de utilidad para depurar problemas relacionados con JWT
class JwtDebugHelper {
  
  /// Analiza y muestra información detallada sobre un token JWT
  static void analyzeJwt(String? token, {String prefix = ''}) {
    if (token == null || token.isEmpty) {
      debugPrint('$prefix[JWT DEBUG] Token nulo o vacío');
      return;
    }

    // Muestra parte del token con seguridad (no el token completo)
    if (token.length > 15) {
      debugPrint('$prefix[JWT DEBUG] Token: ${token.substring(0, 7)}...${token.substring(token.length - 7)}');
    } else {
      debugPrint('$prefix[JWT DEBUG] Token con formato incorrecto (muy corto): $token');
      return;
    }

    // Intenta decodificar el token para obtener información
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('$prefix[JWT DEBUG] Formato de token inválido. Un JWT debe tener 3 partes separadas por puntos.');
        return;
      }

      // Decodificar el encabezado
      final header = _decodeJwtPart(parts[0]);
      debugPrint('$prefix[JWT DEBUG] Encabezado: $header');

      // Decodificar el payload
      final payload = _decodeJwtPart(parts[1]);
      debugPrint('$prefix[JWT DEBUG] Payload: $payload');

      // Verificar la expiración
      if (payload.containsKey('exp')) {
        final expTimestamp = payload['exp'] as int;
        final expDate = DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
        final now = DateTime.now();
        final diff = expDate.difference(now);
        
        debugPrint('$prefix[JWT DEBUG] Expiración: ${expDate.toIso8601String()}');
        
        if (diff.isNegative) {
          debugPrint('$prefix[JWT DEBUG] ALERTA: Token expirado hace ${-diff.inMinutes} minutos');
        } else {
          debugPrint('$prefix[JWT DEBUG] Token válido por ${diff.inMinutes} minutos más');
        }
      } else {
        debugPrint('$prefix[JWT DEBUG] El token no tiene fecha de expiración (exp)');
      }
    } catch (e) {
      debugPrint('$prefix[JWT DEBUG] Error al analizar el token: $e');
    }
  }

  /// Muestra información detallada sobre la respuesta HTTP 401
  static void logUnauthorizedError(dynamic responseBody, {Map<String, String>? requestHeaders}) {
    debugPrint('[JWT ERROR] ===== DETECCIÓN DE ERROR 401 UNAUTHORIZED =====');
    debugPrint('[JWT ERROR] Respuesta del servidor: $responseBody');
    
    if (requestHeaders != null) {
      final authHeader = requestHeaders['Authorization'] ?? 'No presente';
      debugPrint('[JWT ERROR] Header de autorización: $authHeader');
      
      if (authHeader.startsWith('Bearer ') && authHeader.length > 10) {
        final token = authHeader.substring(7); // Remover 'Bearer '
        analyzeJwt(token, prefix: '[JWT ERROR] ');
      }
    }
    
    debugPrint('[JWT ERROR] =============================================');
  }

  /// Registra información detallada sobre un intento de refresh token
  static void logTokenRefresh({
    required bool success,
    String? oldToken,
    String? newToken,
    dynamic serverResponse,
    dynamic error,
  }) {
    debugPrint('[JWT REFRESH] ===== INTENTO DE REFRESH TOKEN =====');
    debugPrint('[JWT REFRESH] Resultado: ${success ? "EXITOSO" : "FALLIDO"}');
    
    if (oldToken != null) {
      debugPrint('[JWT REFRESH] Token original:');
      analyzeJwt(oldToken, prefix: '  ');
    }
    
    if (newToken != null) {
      debugPrint('[JWT REFRESH] Nuevo token:');
      analyzeJwt(newToken, prefix: '  ');
    }
    
    if (serverResponse != null) {
      debugPrint('[JWT REFRESH] Respuesta del servidor: $serverResponse');
    }
    
    if (error != null) {
      debugPrint('[JWT REFRESH] Error: $error');
    }
    
    debugPrint('[JWT REFRESH] ===================================');
  }

  // Decodifica una parte del JWT (header o payload)
  static Map<String, dynamic> _decodeJwtPart(String part) {
    final normalized = base64Url.normalize(part);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded) as Map<String, dynamic>;
  }
}
