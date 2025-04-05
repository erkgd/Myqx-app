/// Clase para manejar excepciones relacionadas con la API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? " (Status: $statusCode)" : ""}';
  }
}

/// Excepción para manejo de errores de autenticación
class AuthException extends ApiException {
  AuthException(String message, {int? statusCode, dynamic data})
      : super(message, statusCode: statusCode, data: data);
}

/// Excepción para errores de red (sin conexión, timeout, etc.)
class NetworkException extends ApiException {
  NetworkException(String message, {int? statusCode, dynamic data})
      : super(message, statusCode: statusCode, data: data);
}

/// Excepción para errores de validación de datos
class ValidationException extends ApiException {
  final Map<String, dynamic>? validationErrors;

  ValidationException(String message, {this.validationErrors, int? statusCode, dynamic data})
      : super(message, statusCode: statusCode, data: data);
}

/// Excepción para respuestas con código 401 (No autorizado)
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {dynamic data})
      : super(message, statusCode: 401, data: data);
}

/// Excepción para respuestas con código 403 (Prohibido)
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {dynamic data})
      : super(message, statusCode: 403, data: data);
}

/// Excepción para respuestas con código 404 (No encontrado)
class NotFoundException extends ApiException {
  NotFoundException(String message, {dynamic data})
      : super(message, statusCode: 404, data: data);
}

/// Excepción para respuestas con códigos 5xx (Error de servidor)
class ServerException extends ApiException {
  ServerException(String message, {int? statusCode, dynamic data})
      : super(message, statusCode: statusCode ?? 500, data: data);
}