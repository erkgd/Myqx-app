// filepath: lib/core/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/exceptions/api_exceptions.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/domain/models/user_model.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';

/// Service for handling general authentication functionality
class AuthService extends ChangeNotifier {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  // Services and utilities
  final SecureStorage _secureStorage = SecureStorage();
  final ApiClient _apiClient = ApiClient();
  final SpotifyAuthService _spotifyAuthService = SpotifyAuthService();
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  SpotifyAuthService get spotifyAuthService => _spotifyAuthService;
  
  AuthService._internal() {
    // Initialize authentication state
    _initAuthState();
  }
  
  // Check if user is already logged in on app start
  Future<void> _initAuthState() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        // Validate token with a request to the server
        _isAuthenticated = await _validateToken();
        if (_isAuthenticated) {
          await _loadUserData();
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Error initializing authentication: ${e.toString()}';
      debugPrint('[AUTH ERROR] $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Validate if the current token is still valid
  Future<bool> _validateToken() async {
    try {
      // Make a request that requires authentication
      // Replace with your actual endpoint
      final response = await _apiClient.get('/auth/validate');
      return response != null && response['valid'] == true;
    } catch (e) {
      debugPrint('[AUTH ERROR] Token validation failed: ${e.toString()}');
      return false;
    }
  }
  
  // Load user data from API
  Future<void> _loadUserData() async {
    try {
      final userData = await _apiClient.get('/users/me');
      if (userData != null) {
        // Convert API response to User model
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('[AUTH ERROR] Failed to load user data: ${e.toString()}');
    }
  }
  
  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      }, requiresAuth: false);
      
      if (response != null && response['token'] != null) {
        // Save token to secure storage
        await _secureStorage.saveToken(response['token']);
        
        // Save user ID if provided
        if (response['userId'] != null) {
          await _secureStorage.saveUserId(response['userId']);
        }
        
        _isAuthenticated = true;
        await _loadUserData();
        return true;
      } else {
        _errorMessage = 'Invalid login response from server';
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Login error: ${e.toString()}';
      }
      debugPrint('[AUTH ERROR] $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Register a new user
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.post('/auth/register', body: {
        'name': name,
        'email': email,
        'password': password,
      }, requiresAuth: false);
      
      if (response != null && response['success'] == true) {
        // Auto login after successful registration
        return await login(email, password);
      } else {
        _errorMessage = response?['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Registration error: ${e.toString()}';
      }
      debugPrint('[AUTH ERROR] $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Logout the user
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Clear local authentication data
      await _secureStorage.deleteToken();
      await _secureStorage.deleteUserId();
      
      // Reset state
      _isAuthenticated = false;
      _currentUser = null;
      
      return true;
    } catch (e) {
      _errorMessage = 'Logout error: ${e.toString()}';
      debugPrint('[AUTH ERROR] $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Check if the User model needs to be saved
  void _notifyAuthChange() {
    notifyListeners();
  }
}
