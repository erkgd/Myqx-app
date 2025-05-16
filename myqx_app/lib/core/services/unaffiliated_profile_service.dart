
import 'package:flutter/foundation.dart';
import 'package:myqx_app/core/http/api_client.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/core/services/spotify_track_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';



/// Servicio para cargar y gestionar perfiles de usuarios no afiliados
///
/// Este servicio proporciona métodos para cargar perfiles de usuarios desde la API:
/// - Endpoint principal: /profile/{userId} para obtener datos completos del perfil
/// - Endpoint para estados de seguimiento: /users/following/status/{userId}
/// - Endpoint para seguir/dejar de seguir: /users/following/{id_follower}/{id_followed}
/// 
/// Principales características:
/// - Caché automática de perfiles con tiempo de expiración configurable
/// - Carga progresiva mostrando datos en caché mientras se actualizan en segundo plano
/// - Precarga de perfiles populares para mejorar la experiencia de usuario
class UnaffiliatedProfileService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final SpotifyTrackService _trackService;

  
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
    SpotifyTrackService? trackService,
  }) : 
    _apiClient = apiClient ?? ApiClient(),
    _secureStorage = secureStorage ?? SecureStorage(),
    _trackService = trackService ?? SpotifyTrackService();

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
      
      // Realizar petición a la ruta correcta de la API
      final response = await _apiClient.get('/profile/$userId', requiresAuth: true);
      
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
  void _processResponseData(Map<String, dynamic> data) async {
    try {
      // Procesar datos básicos del usuario
      _profileUser = SpotifyUser(
        id: data['userId'] ?? data['spotifyId'] ?? '',
        displayName: data['username'] ?? 'Usuario',
        email: null,
        imageUrl: data['profileImage'],
        spotifyUrl: data['spotifyUrl'] ?? 'https://open.spotify.com/',
        followers: 0,
      );
      
      // Recolectar IDs de pistas para obtener información de Spotify
      final Set<String> trackIds = {};
      SpotifyTrack? topRatedTrackTemp;
      
      // Procesar canciones de las calificaciones recientes para mostrarlas como álbumes
      _topAlbums = [];
      if (data['recentRatings'] != null && data['recentRatings'] is List) {
        final ratings = data['recentRatings'] as List;
        // Primero crear álbumes con los datos disponibles
        for (final rating in ratings) {
          final trackId = rating['trackId'] ?? '';
          if (trackId.isNotEmpty) {
            trackIds.add(trackId);
          }
          
          _topAlbums.add(SpotifyAlbum(
            id: trackId,
            name: rating['title'] ?? 'Pista desconocida',
            artistName: rating['artist'] ?? 'Artista desconocido',
            artistId: '', // No disponible en los datos iniciales
            coverUrl: rating['imageUrl'] ?? '',
            releaseDate: rating['date']?.toString().split('T')[0] ?? '2025-01-01',
            totalTracks: 1,
            spotifyUrl: 'https://open.spotify.com/track/$trackId',
          ));
        }
      }
      
      // Procesar canción mejor valorada como starOfTheDay
      if (data['topRatedTrack'] != null) {
        final track = data['topRatedTrack'];
        final trackId = track['trackId'] ?? '';
        
        if (trackId.isNotEmpty) {
          trackIds.add(trackId);
        }
        
        topRatedTrackTemp = SpotifyTrack(
          id: trackId,
          name: track['title'] ?? 'Pista desconocida',
          artistName: track['artist'] ?? 'Artista desconocido',
          albumName: '', // No disponible en los datos iniciales
          imageUrl: track['imageUrl'],
          spotifyUrl: 'https://open.spotify.com/track/$trackId',
          albumId: null,
        );
        
        _starOfTheDay = topRatedTrackTemp;
      }
      
      // Calcular compatibilidad basada en calificaciones promedio
      _compatibility = data['averageRating'] != null 
          ? (data['averageRating'] / 5.0) * 100.0 // Convertir de 5 a 100
          : 0.0;
          
      // Iniciar proceso en segundo plano para obtener datos adicionales de Spotify
      _enrichWithSpotifyData(trackIds.toList());
    } catch (e) {
      debugPrint('[ERROR] Error al procesar datos de perfil: $e');
      // Si ocurre un error, no actualizamos los datos para mantener los anteriores
    }
  }
  /// Método para procesar la respuesta cuando viene en formato directo (sin campo 'data')
  void _processDirectResponse(Map<String, dynamic> response) async {
    try {
      // Recolectar IDs de pistas para obtenerlas de Spotify
      final Set<String> trackIds = {};
      
      // Si tenemos datos básicos directamente en el root
      if (response['userId'] != null || response['username'] != null) {
        _profileUser = SpotifyUser(
          id: response['userId'] ?? response['spotifyId'] ?? '',
          displayName: response['username'] ?? 'Usuario',
          email: null,
          imageUrl: response['profileImage'],
          spotifyUrl: response['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      } 
      // Formato anterior con campo 'user'
      else if (response['user'] != null) {
        _profileUser = SpotifyUser(
          id: response['user']['spotifyId'] ?? '',
          displayName: response['user']['username'] ?? 'Usuario',
          email: null,
          imageUrl: response['user']['profileImage'],
          spotifyUrl: response['user']['spotifyUrl'] ?? 'https://open.spotify.com/',
          followers: 0,
        );
      }
      
      // Procesar ratings como álbumes (nuevo formato)
      _topAlbums = [];
      if (response['recentRatings'] != null && response['recentRatings'] is List) {
        final ratings = response['recentRatings'] as List;
        for (final rating in ratings) {
          final trackId = rating['trackId'] ?? '';
          if (trackId.isNotEmpty) {
            trackIds.add(trackId);
          }
          
          _topAlbums.add(SpotifyAlbum(
            id: trackId,
            name: rating['title'] ?? 'Pista desconocida',
            artistName: rating['artist'] ?? 'Artista desconocido',
            artistId: '', 
            coverUrl: rating['imageUrl'] ?? '',
            releaseDate: rating['date']?.toString().split('T')[0] ?? '2025-01-01',
            totalTracks: 1,
            spotifyUrl: 'https://open.spotify.com/track/$trackId',
          ));
        }
      } 
      // Mantener compatibilidad con el formato anterior
      else if (response['top_albums'] != null) {
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
      
      // Procesar canción destacada (nuevo formato)
      if (response['topRatedTrack'] != null) {
        final track = response['topRatedTrack'];
        final trackId = track['trackId'] ?? '';
        
        if (trackId.isNotEmpty) {
          trackIds.add(trackId);
        }
        
        _starOfTheDay = SpotifyTrack(
          id: trackId,
          name: track['title'] ?? 'Pista desconocida',
          artistName: track['artist'] ?? 'Artista desconocido',
          albumName: '',
          imageUrl: track['imageUrl'],
          spotifyUrl: 'https://open.spotify.com/track/$trackId',
          albumId: null,
        );
      }
      // Mantener compatibilidad con el formato anterior
      else if (response['star_track'] != null) {
        final track = response['star_track'];
        try {
          final trackId = track['id'] ?? '';
          
          if (trackId.isNotEmpty) {
            trackIds.add(trackId);
          }
          
          _starOfTheDay = SpotifyTrack(
            id: trackId,
            name: track['name'] ?? 'Pista desconocida',
            artistName: track['artist_name'] ?? 'Artista desconocido',
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
      
      // Calcular compatibilidad
      if (response['averageRating'] != null) {
        _compatibility = (response['averageRating'] / 5.0) * 100.0; // Convertir de 5 a 100
      } else {
        // Formato anterior
        _compatibility = response['compatibility']?.toDouble() ?? 0.0;
      }
      
      // Enriquecer datos con información de Spotify
      if (trackIds.isNotEmpty) {
        _enrichWithSpotifyData(trackIds.toList());
      }
    } catch (e) {
      debugPrint('[ERROR] Error al procesar respuesta directa: $e');
    }
  }  /// Método para comprobar si el usuario actual sigue al usuario del perfil
  Future<bool> isFollowing(String userId) async {
    try {
      // Obtenemos el ID del usuario actual
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('[ERROR] No se pudo obtener el ID del usuario actual para verificar seguimiento');
        return false;
      }
      
      // Si estamos verificando nuestro propio perfil, no nos podemos seguir a nosotros mismos
      if (currentUserId == userId) {
        debugPrint('[INFO] No se puede seguir a uno mismo');
        return false;
      }
      
      // Utilizamos la ruta correcta según la API: /users/following/status/{id_follower}/{id_followed}
      final response = await _apiClient.get('/users/following/status/$currentUserId/$userId');
      debugPrint('[DEBUG] Estado de seguimiento (respuesta completa): ${response.toString()}');
      
      // Verificar la estructura de la respuesta y acceder al estado de seguimiento
      bool isFollowing = false;
      
      // Verificar si el valor está dentro del campo 'data'
      if (response['data'] != null && response['data']['is_following'] != null) {
        isFollowing = response['data']['is_following'] == true;
        debugPrint('[DEBUG] Estado de seguimiento encontrado en data.is_following: $isFollowing');
      } 
      // Verificar si está directamente en la raíz de la respuesta
      else if (response['is_following'] != null) {
        isFollowing = response['is_following'] == true;
        debugPrint('[DEBUG] Estado de seguimiento encontrado en is_following: $isFollowing');
      }
      
      debugPrint('[DEBUG] Estado de seguimiento final: $isFollowing');
      return isFollowing;
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
      
      // Usar el formato correcto de la ruta: /users/following/{id_follower}/{id_followed}
      final response = await _apiClient.post('/users/following/$currentUserId/$userId');
      
      debugPrint('[DEBUG] Petición de seguir enviada a: /users/following/$currentUserId/$userId');
      debugPrint('[DEBUG] Respuesta del servidor: ${response.toString()}');
      
      // Verificar si la respuesta fue exitosa basándose en el campo 'status'
      bool isSuccess = false;
      
      if (response['success'] != null) {
        // Formato antiguo que usa campo 'success'
        isSuccess = response['success'] == true;
      } else if (response['status'] != null) {
        // Formato nuevo que usa campo 'status'
        isSuccess = response['status'] == 'success';
      }
      
      debugPrint('[DEBUG] Operación de follow exitosa: $isSuccess');
      return isSuccess;
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
        // Usar el formato correcto de la ruta: /users/following/{id_follower}/{id_followed}
      final response = await _apiClient.delete('/users/following/$currentUserId/$userId');
      
      debugPrint('[DEBUG] Petición de dejar de seguir enviada a: /users/following/$currentUserId/$userId');
      debugPrint('[DEBUG] Respuesta del servidor: ${response.toString()}');
      
      // Verificar si la respuesta fue exitosa basándose en el campo 'status'
      bool isSuccess = false;
      
      if (response['success'] != null) {
        // Formato antiguo que usa campo 'success'
        isSuccess = response['success'] == true;
      } else if (response['status'] != null) {
        // Formato nuevo que usa campo 'status'
        isSuccess = response['status'] == 'success';
        
        // También verificar si hay información adicional en el campo 'data'
        if (response['data'] != null && response['data']['status'] == 'unfollowed') {
          debugPrint('[DEBUG] Estado de unfollowed confirmado en data.status');
          isSuccess = true;
        }
      }
      
      debugPrint('[DEBUG] Operación de unfollow exitosa: $isSuccess');
      return isSuccess;
    } catch (e) {
      debugPrint('[ERROR] Error al dejar de seguir al usuario: ${e.toString()}');
      _errorMessage = 'No se pudo dejar de seguir al usuario: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  /// Método para calcular compatibilidad
  double calculateCompatibility() {
    // Asegurarse que la compatibilidad esté entre 0 y 100
    if (_compatibility < 0) return 0;
    if (_compatibility > 100) return 100;
    return _compatibility;
  }
  // Flag para evitar llamadas simultáneas al enriquecimiento de datos
  bool _isEnrichingData = false;
  // Flag para indicar que los datos están completamente cargados
  bool _dataFullyLoaded = false;
  
  // Getter para saber si los datos están completamente cargados
  bool get dataFullyLoaded => _dataFullyLoaded;
  
  /// Método para enriquecer los datos con información de Spotify
  Future<void> _enrichWithSpotifyData(List<String> trackIds) async {
    // Si no hay IDs para enriquecer o ya está en proceso, salir inmediatamente
    if (trackIds.isEmpty) {
      debugPrint('[WARNING] No hay IDs de pistas para enriquecer');
      return;
    }
    
    // Evitar llamadas simultáneas al mismo método
    if (_isEnrichingData) {
      debugPrint('[INFO] Ya se está ejecutando el enriquecimiento de datos, ignorando llamada');
      return;
    }
    
    _isEnrichingData = true;
    _dataFullyLoaded = false; // Comenzando la carga completa
    
    debugPrint('[DEBUG] Enriqueciendo ${trackIds.length} pistas con datos de Spotify');
    
    try {
      // Obtener detalles de todas las pistas
      final spotifyTracks = await _trackService.getTracksById(trackIds);
      if (spotifyTracks.isEmpty) {
        debugPrint('[WARNING] No se pudieron obtener detalles de Spotify para ninguna pista');
        _isEnrichingData = false;
        return;
      }
      
      debugPrint('[DEBUG] Obtenidos detalles para ${spotifyTracks.length} pistas');
      
      // Crear un mapa para acceso rápido por ID
      final Map<String, SpotifyTrack> tracksMap = {
        for (var track in spotifyTracks) track.id: track
      };
      
      // Actualizar la pista mejor valorada con datos de Spotify
      if (_starOfTheDay != null && tracksMap.containsKey(_starOfTheDay!.id)) {
        _starOfTheDay = tracksMap[_starOfTheDay!.id];
      }
        // Actualizar los álbumes (que son en realidad pistas)
      for (int i = 0; i < _topAlbums.length; i++) {
        final albumId = _topAlbums[i].id; // En realidad es un trackId
        if (tracksMap.containsKey(albumId)) {
          final track = tracksMap[albumId]!;
          _topAlbums[i] = SpotifyAlbum(
            id: albumId,
            name: track.name,
            artistName: track.artistName,
            artistId: '', // No disponible fácilmente
            coverUrl: track.imageUrl ?? '',
            releaseDate: _topAlbums[i].releaseDate,
            totalTracks: 1,
            spotifyUrl: track.spotifyUrl,
          );
        }
      }
      
      // Marcar como completamente cargado y notificar explícitamente
      _dataFullyLoaded = true;
      
      debugPrint('[DEBUG] Enriquecimiento de datos completado. Actualizando UI...');
      
      // Notificar a los oyentes sobre los cambios
      notifyListeners();
      
    } catch (e) {
      debugPrint('[ERROR] Error al enriquecer datos con Spotify: $e');
    } finally {
      _isEnrichingData = false;
    }
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
  
  
  
}
