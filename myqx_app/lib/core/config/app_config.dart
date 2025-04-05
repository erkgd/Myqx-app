import 'package:flutter/foundation.dart' show kReleaseMode;

class AppConfig {
  // Constantes para la API
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String loginEndpoint = '/auth';
  static const String userEndpoint = '/users';
  static const String healthCheckEndpoint = '/health';
  
  // Timeout para solicitudes HTTP (en segundos)
  static const int requestTimeout = 15;
  
  // Configuración según ambiente
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => !kReleaseMode;
  
  // URLs de la API según ambiente
  static String get apiBaseUrl => isProduction 
    ? 'https://api.myqx.com/api' 
    : 'http://10.0.2.2:8000/api';  // Para emulador Android
  
  // Configuración de almacenamiento
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Constantes de la app
  static const String appName = 'MyQx';
  static const String appVersion = '1.0.0';
}