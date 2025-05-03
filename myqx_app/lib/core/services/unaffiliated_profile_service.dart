import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/data/models/spotify_models.dart';

/// Servicio para cargar y gestionar perfiles de usuarios no afiliados
///
/// Este servicio proporciona métodos para cargar perfiles de usuarios desde la API:
/// - Endpoint principal: /api/profile/{userId} para obtener datos completos del perfil
/// 
/// Principales características:
/// - Caché automática de perfiles con tiempo de expiración configurable
/// - Carga progresiva mostrando datos en caché mientras se actualizan en segundo plano
/// - Precarga de perfiles populares para mejorar la experiencia de usuario
class UnaffiliatedProfileService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  
  // Estado observable
  SpotifyUser? _profileUser;
  List<SpotifyAlbum> _topAlbums = [];
  SpotifyTrack? _starOfTheDay;
  bool _isLoading = false;
  String? _errorMessage;
  double _compatibility = 0.0;

  // Getters para acceder al estado
  SpotifyUser? get profileUser => _profileUser;
  List<SpotifyAlbum> get topAlbums => _topAlbums;
  SpotifyTrack? get starOfTheDay => _starOfTheDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get compatibility => _compatibility;

  UnaffiliatedProfileService({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
  }) : 
    _apiClient = apiClient ?? ApiClient(),
    _secureStorage = secureStorage ?? SecureStorage();

  // Caché de perfiles para carga rápida
  static final Map<String, Map<String, dynamic>> _profileCache = {};
  
  // Timestamp de última actualización para cada perfil
  static final Map<String, DateTime> _lastFetchTime = {};
  
  // Duración de validez de la caché (10 minutos)
  static const Duration _cacheDuration = Duration(minutes: 10);
  
  /// Método principal para cargar perfil de usuario no afiliado
  ///
  /// Este método primero verifica en caché y luego hace una petición a la API si es necesario
  Future<void> loadProfileById(String userId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('[DEBUG] Cargando perfil no afiliado con ID: $userId');
      
      // Verificar si tenemos datos en caché y si son recientes
      final bool hasCachedData = _profileCache.containsKey(userId);
      final bool isCacheValid = hasCachedData && 
          (_lastFetchTime[userId]?.isAfter(DateTime.now().subtract(_cacheDuration)) ?? false);
      
      // Si hay caché válida, usarla primero (mientras se actualiza en segundo plano)
      if (isCacheValid) {
        debugPrint('[DEBUG] Usando datos en caché para perfil $userId');
        _processApiResponse(_profileCache[userId]!);
        
        // Notificar para mostrar inmediatamente los datos en caché
        _isLoading = false;
        notifyListeners();
        
        // Si la caché es reciente pero no fresca (más de 2 minutos),
        // actualizamos en segundo plano sin bloquear la UI
        if (_lastFetchTime[userId]!.isBefore(DateTime.now().subtract(const Duration(minutes: 2)))) {
          _updateProfileInBackground(userId);
        } else {
          debugPrint('[DEBUG] Caché muy reciente, omitiendo actualización en segundo plano');
        }
        return;
      }
      
      // Si no hay caché válida, hacer la petición a la API
      final success = await fetchProfileFromApi(userId);
      
      // Si falla la petición a la API, mostramos error
      if (!success) {
        _errorMessage = 'No se pudieron cargar los datos del perfil';
      }
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      debugPrint('[ERROR] Error al cargar el perfil: ${e.toString()}');
      _errorMessage = 'Error al cargar los datos del perfil: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Realiza una petición a la API de perfiles
  ///
  /// [userId] - ID del usuario cuyo perfil queremos obtener
  /// Retorna true si la operación fue exitosa
  Future<bool> fetchProfileFromApi(String userId) async {
    try {
      debugPrint('[DEBUG] Solicitando perfil a la API para ID: $userId');
      
      // Realizar petición a la nueva ruta de la API
      final response = await _apiClient.get('/api/profile/$userId', requiresAuth: true);
      
      debugPrint('[DEBUG] Respuesta de la API de perfil obtenida con éxito');
      
      // Guardar en caché para futuros accesos
      _profileCache[userId] = response;
      _lastFetchTime[userId] = DateTime.now();
      
      // Procesar la respuesta
      _processApiResponse(response);
      
      return true;
    } catch (e) {
      debugPrint('[ERROR] Error al solicitar perfil desde la API: ${e.toString()}');
      _errorMessage = 'Error al solicitar perfil desde la API: ${e.toString()}';
      return false;
    }
  }
  
  /// Actualiza el perfil en segundo plano sin bloquear la UI
  void _updateProfileInBackground(String userId) async {
    try {
      debugPrint('[DEBUG] Actualizando perfil en segundo plano: $userId');
      final success = await fetchProfileFromApi(userId);
      
      if (success) {
        debugPrint('[DEBUG] Perfil actualizado en segundo plano exitosamente');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[WARNING] Error en actualización de perfil en segundo plano: ${e.toString()}');
      // No actualizamos el estado de error ya que esto es en segundo plano
    }
  }
  
  /// Procesa la respuesta de la API
  void _processApiResponse(Map<String, dynamic> response) {
    try {
      // Verificar si la respuesta tiene la estructura esperada
      if (response['data'] != null) {
        debugPrint('[DEBUG] Usando datos del campo "data" de la respuesta');
        _processResponseData(response['data']);
      } else {
        debugPrint('[DEBUG] Respuesta sin campo "data", procesando directamente');
        _processDirectResponse(response);
      }
    } catch (e) {
      debugPrint('[ERROR] Error al procesar respuesta de la API: $e');
      _errorMessage = 'Error al procesar la respuesta: ${e.toString()}';
    }
  }
  
  /// Método para procesar los datos de la respuesta cuando están en el campo 'data'
  void _processResponseData(Map<String, dynamic> data) {
    try {
      // Procesar datos básicos del usuario
      if (data['user'] != null) {
        _profileUser = SpotifyUser(
          id: data['user']['spotifyId'] ?? '',
          displayName: data['user']['username'] ?? 'Usuario',
          email: null,
          imageUrl: data['user']['profileImage'],
          spotifyUrl: data['user']['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      }
      
      // Procesar álbumes
      _topAlbums = [];
      if (data['top_albums'] != null) {
        for (final album in data['top_albums']) {
          _topAlbums.add(SpotifyAlbum(
            id: album['id'] ?? '',
            name: album['name'] ?? 'Unknown Album',
            artistName: album['artist_name'] ?? 'Unknown Artist',
            artistId: album['artist_id'] ?? '',
            coverUrl: album['image_url'] ?? '',
            releaseDate: album['release_date'] ?? '2025-01-01',
            totalTracks: album['total_tracks'] ?? 1,
            spotifyUrl: album['spotify_url'] ?? '',
          ));
        }
      }
      
      // Procesar canción destacada
      if (data['star_track'] != null) {
        final track = data['star_track'];
        _starOfTheDay = SpotifyTrack(
          id: track['id'] ?? '',
          name: track['name'] ?? 'Unknown Track',
          artistName: track['artist_name'] ?? 'Unknown Artist',
          albumName: track['album_name'] ?? '',
          imageUrl: track['image_url'] ?? '',
          spotifyUrl: track['spotify_url'] ?? '',
          albumId: track['album_id'],
        );
      }
      
      // Procesar compatibilidad
      _compatibility = data['compatibility']?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('[ERROR] Error al procesar datos de perfil: $e');
      // Si ocurre un error, no actualizamos los datos para mantener los anteriores
    }
  }
  
  /// Método para procesar la respuesta cuando viene en formato directo (sin campo 'data')
  void _processDirectResponse(Map<String, dynamic> response) {
    try {
      // Procesar usuario
      if (response['user'] != null) {
        _profileUser = SpotifyUser(
          id: response['user']['spotifyId'] ?? '',
          displayName: response['user']['username'] ?? 'Usuario',
          email: null,
          imageUrl: response['user']['profileImage'],
          spotifyUrl: response['user']['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      } else if (response['username'] != null) {
        _profileUser = SpotifyUser(
          id: response['spotifyId'] ?? '',
          displayName: response['username'] ?? 'Usuario',
          email: null,
          imageUrl: response['profileImage'],
          spotifyUrl: response['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      }
      
      // Procesar álbumes
      _topAlbums = [];
      if (response['top_albums'] != null) {
        for (final album in response['top_albums']) {
          _topAlbums.add(SpotifyAlbum(
            id: album['id'] ?? '',
            name: album['name'] ?? 'Unknown Album',
            artistName: album['artist_name'] ?? 'Unknown Artist',
            artistId: album['artist_id'] ?? '',
            coverUrl: album['image_url'] ?? '',
            releaseDate: album['release_date'] ?? '2025-01-01',
            totalTracks: album['total_tracks'] ?? 1,
            spotifyUrl: album['spotify_url'] ?? '',
          ));
        }
      }
      
      // Procesar canción destacada
      if (response['star_track'] != null) {
        final track = response['star_track'];
        try {
          _starOfTheDay = SpotifyTrack(
            id: track['id'] ?? '',
            name: track['name'] ?? 'Unknown Track',
            artistName: track['artist_name'] ?? 'Unknown Artist',
            albumName: track['album_name'] ?? '',
            imageUrl: track['image_url'] ?? '',
            spotifyUrl: track['spotify_url'] ?? '',
            albumId: track['album_id'],
          );
        } catch (e) {
          debugPrint('[ERROR] Error al crear SpotifyTrack: $e');
          _starOfTheDay = null;
        }
      }
      
      // Procesar compatibilidad
      _compatibility = response['compatibility']?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('[ERROR] Error al procesar respuesta directa: $e');
    }
  }
    /// Método para comprobar si el usuario actual sigue al usuario del perfil
  Future<bool> isFollowing(String userId) async {
    try {
      // Obtenemos el ID del usuario actual
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('[ERROR] No se pudo obtener el ID del usuario actual para verificar seguimiento');
        return false;
      }
      
      // Utilizamos la ruta correcta según la API
      final response = await _apiClient.get('/api/following/status/$currentUserId/$userId');
      debugPrint('[DEBUG] Estado de seguimiento: ${response.toString()}');
      return response['is_following'] ?? false;
    } catch (e) {
      debugPrint('[ERROR] Error al verificar si sigue al usuario: ${e.toString()}');
      return false;
    }
  }
    /// Método para seguir a un usuario
  Future<bool> followUser(String userId) async {
    try {
      // Obtener el ID del usuario actual
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('[ERROR] No se pudo obtener el ID del usuario actual para seguir');
        return false;
      }
      
      // Usar el formato correcto de la ruta: /api/following/{id_follower}/{id_followed}
      final response = await _apiClient.post('/api/following/$currentUserId/$userId');
      
      debugPrint('[DEBUG] Petición de seguir enviada a: /api/following/$currentUserId/$userId');
      debugPrint('[DEBUG] Respuesta del servidor: ${response.toString()}');
      
      return response['success'] ?? false;
    } catch (e) {
      debugPrint('[ERROR] Error al seguir al usuario: ${e.toString()}');
      _errorMessage = 'No se pudo seguir al usuario: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
    /// Método para dejar de seguir a un usuario
  Future<bool> unfollowUser(String userId) async {
    try {
      // Obtener el ID del usuario actual
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('[ERROR] No se pudo obtener el ID del usuario actual para dejar de seguir');
        return false;
      }
      
      // Usar el formato correcto de la ruta: /api/following/{id_follower}/{id_followed}
      final response = await _apiClient.delete('/api/following/$currentUserId/$userId');
      
      debugPrint('[DEBUG] Petición de dejar de seguir enviada a: /api/following/$currentUserId/$userId');
      debugPrint('[DEBUG] Respuesta del servidor: ${response.toString()}');
      
      return response['success'] ?? false;
    } catch (e) {
      debugPrint('[ERROR] Error al dejar de seguir al usuario: ${e.toString()}');
      _errorMessage = 'No se pudo dejar de seguir al usuario: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  /// Método para calcular compatibilidad
  double calculateCompatibility() {
    return _compatibility;
  }
  
  /// Método para limpiar todos los datos
  void clear() {
    _profileUser = null;
    _topAlbums = [];
    _starOfTheDay = null;
    _errorMessage = null;
    _compatibility = 0.0;
    notifyListeners();
  }
  
  /// Método para precargar perfiles populares o recomendados
  /// Útil para cargar en segundo plano perfiles que el usuario probablemente visite
  Future<void> preloadPopularProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return;
    
    debugPrint('[DEBUG] Precargando ${userIds.length} perfiles populares');
    
    // Limitamos la cantidad de perfiles a precargar para no sobrecargar la red
    final limitedIds = userIds.length > 5 ? userIds.sublist(0, 5) : userIds;
    
    // No notificamos cambios ya que esto se hace en segundo plano
    try {
      for (final userId in limitedIds) {
        // Verificamos si ya tenemos el perfil en caché y si es reciente
        final bool hasCachedData = _profileCache.containsKey(userId);
        final bool isCacheValid = hasCachedData && 
            (_lastFetchTime[userId]?.isAfter(DateTime.now().subtract(_cacheDuration)) ?? false);
        
        // Si no tenemos caché o está desactualizada, cargar
        if (!isCacheValid) {
          debugPrint('[DEBUG] Precargando perfil: $userId');
          
          // Agregamos un pequeño retardo para no saturar la API
          await Future.delayed(const Duration(milliseconds: 500));
          
          await fetchProfileFromApi(userId);
          debugPrint('[DEBUG] Perfil $userId precargado con éxito');
        }
      }
    } catch (e) {
      // Capturamos errores pero no los propagamos ya que esto es una mejora opcional
      debugPrint('[WARNING] Error al precargar perfiles: $e');
    }
  }
  
}
