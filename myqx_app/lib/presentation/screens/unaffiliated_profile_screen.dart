import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/unaffiliated_profile_service.dart';
import 'package:myqx_app/core/services/performance_service.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/presentation/widgets/profile/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/profile/top_five_albums.dart';
import 'package:myqx_app/presentation/widgets/profile/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/general/lazy_image.dart';

class UnaffiliatedProfileScreen extends StatefulWidget {
  final String userId;
  final String? profileImageUrl; // Añadido para recibir la URL de la imagen de perfil

  const UnaffiliatedProfileScreen({
    super.key,
    required this.userId,
    this.profileImageUrl, // Parámetro opcional para la URL de la imagen
  });

  @override
  State<UnaffiliatedProfileScreen> createState() => _UnaffiliatedProfileScreenState();
}

class _UnaffiliatedProfileScreenState extends State<UnaffiliatedProfileScreen> with WidgetsBindingObserver {
  bool _isFollowing = false;
  bool _isLoading = true;
  bool _isFollowActionLoading = false; // Estado específico para el botón de follow
  late final UnaffiliatedProfileService _profileService;
  final PerformanceService _performanceService = PerformanceService();
  final SecureStorage _secureStorage = SecureStorage();
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar el servicio con las dependencias necesarias
    _profileService = UnaffiliatedProfileService();
    
    // Añadir listener para actualizaciones de datos de Spotify
    _profileService.addListener(_handleProfileUpdates);
    
    // Registrar observer para ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar datos del perfil inmediatamente al abrir la pantalla
    _loadProfileDataProgressive();
  }
  
  /// Maneja las actualizaciones del servicio de perfil
  void _handleProfileUpdates() {
    if (mounted) {
      // Forzar reconstrucción de la UI cuando hay cambios en los datos
      setState(() {
        debugPrint("[INFO] Actualizando UI debido a cambios en los datos de perfil");
      });
    }
  }
  
  @override
  void dispose() {
    // Quitar el listener para evitar memory leaks
    _profileService.removeListener(_handleProfileUpdates);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Recargar datos solo si han pasado más de 5 minutos desde la última carga
      if (_shouldRefreshData()) {
        _loadProfileDataProgressive();
      }
    }
  }
  
  bool _shouldRefreshData() {
    // Check if we need to refresh - for example if it's been more than 5 minutes
    // This would be determined by checking the timestamp of the last fetch
    return true; // Default to refreshing for now
  }
    /// Loads profile data progressively, prioritizing critical UI elements
  Future<void> _loadProfileDataProgressive() async {
    if (mounted) {  
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      debugPrint("[DEBUG] Profile: Starting progressive loading for ID: ${widget.userId}");
      
      // Verificar primero si el usuario está autenticado para cargar el estado de seguimiento temprano
      final isAuthenticated = await _secureStorage.isAuthenticated();
      
      // Step 1: Load basic user data (highest priority)
      await _profileService.loadProfileById(widget.userId);
      
      // Step 2: Cargar el estado de seguimiento ANTES de marcar la carga como completa
      if (isAuthenticated) {
        await _loadFollowingStatus();
        debugPrint("[DEBUG] Estado de seguimiento cargado: $_isFollowing");
      } else {
        debugPrint("[INFO] Usuario no autenticado. No se verifica estado de seguimiento");
      }
      
      if (mounted) {
        setState(() {
          // We can show the UI now with the user data loaded
          _isLoading = false;
        });
      }
      
      // Step 3: Schedule lower-priority data loading using the performance service
      _performanceService.scheduleDeferredWork(() {
        // This will run after the main UI is displayed
        debugPrint("[DEBUG] Loading additional profile data in background");
      });
      
    } catch (e) {
      debugPrint("[ERROR] Failed to load initial profile data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
    /// Loads profile data with optimized loading strategy
  Future<void> _loadProfileData() async {
    if (mounted) {  
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      debugPrint("[DEBUG] Profile: Optimized loading for ID: ${widget.userId}");
      
      // Verificar autenticación primero
      final isAuthenticated = await _secureStorage.isAuthenticated();
      
      // Step 1: Load basic user data (highest priority)
      await _profileService.loadProfileById(widget.userId);
      
      // Step 2: Check following status
      if (isAuthenticated) {
        await _loadFollowingStatus();
        debugPrint("[DEBUG] Following status after reload: $_isFollowing");
      }
      
      debugPrint("[DEBUG] Profile: Data loaded successfully");
    } catch (e) {
      debugPrint("[ERROR] Failed to load profile data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }  
  
  Future<void> _loadFollowingStatus() async {
    try {
      // Ya verificamos la autenticación antes de llamar a este método
      // Así que podemos asumir que el usuario está autenticado
      
      // Verificar si el usuario es el mismo (no se puede seguir a uno mismo)
      final currentUserId = await _secureStorage.getUserId();
      if (currentUserId == widget.userId) {
        debugPrint("[INFO] No se puede seguir a uno mismo");
        return;
      }
      
      // Solo verificar estado de seguimiento si los IDs son diferentes
      try {
        bool isFollowing = false;
        isFollowing = await _profileService.isFollowing(widget.userId);
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
          });
          
          // Depuración del estado del botón
          debugPrint("[DEBUG] Estado de seguimiento actualizado: ${_isFollowing ? 'Following' : 'Not following'}");
          debugPrint("[DEBUG] Botón debe mostrar: ${_isFollowing ? 'Unfollow' : 'Follow'}");
        }
      } catch (apiError) {
        // Capturar errores específicos de la API
        debugPrint("[WARNING] Error API al verificar estado de seguimiento: $apiError");
      }
    } catch (e) {
      // Si hay un error general, lo registramos pero no cambiamos el estado
      debugPrint("[ERROR] Error general al verificar estado de seguimiento: $e");
    }
  }

    // Se han eliminado los métodos de carga progresiva
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const UserHeader(),
      body: _buildBody(),
    );
  }
    Widget _buildBody() {
    // Si el servicio está cargando pero tenemos datos en caché, mostrar contenido con indicador
    final bool isServiceLoading = _profileService.isLoading;
    final bool hasProfileData = _profileService.profileUser != null;
      if (_isLoading && !hasProfileData) {
      // Implementar el círculo de carga estilizado similar al profile_screen.dart
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo exterior decorativo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CorporativeColors.mainColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              // Círculo interior con gradiente y animación
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CorporativeColors.mainColor,
                      width: 3,
                    ),
                  ),
                  // Círculo de carga animado
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CorporativeColors.mainColor),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Texto de carga
            const Text(
              'Cargando perfil...',
              style: TextStyle(
                color: CorporativeColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (hasProfileData) {
      return Stack(
        children: [
          // Contenido principal
          _buildProfileContent(),
          
          // Indicador de carga superpuesto si está actualizando
          if (isServiceLoading)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SizedBox(
                  width: 20, 
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // No hay datos ni está cargando inicialmente
      return _buildErrorState();
    }
  }
    // El método _buildSkeletonLoading ha sido eliminado
    Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _profileService.errorMessage ?? "No se pudieron cargar los datos del perfil",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfileData,
            child: const Text("Intentar de nuevo"),
          ),
        ],
      ),
    );
  }
    Widget _buildProfileContent() {
    final user = _profileService.profileUser;
    final starTrack = _profileService.starOfTheDay;
    final topAlbums = _profileService.topAlbums;
    
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Failed to load profile",
              style: TextStyle(
                color: CorporativeColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _profileService.errorMessage ?? "Unknown error",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProfileDataProgressive,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
    
    // Usar la URL de la imagen pasada desde GraphScreen si está disponible
    final imageUrl = widget.profileImageUrl ?? user.imageUrl;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),            // Profile circle with optimized image loading (tamaño reducido)
            Container(
              width: 120, // Reducido de 160 a 120
              height: 120, // Reducido de 160 a 120
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CorporativeColors.mainColor,
                  width: 2, // Reducido de 3 a 2
                ),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? LazyImage(
                        imageUrl: imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(CorporativeColors.mainColor),
                          ),
                        ),
                        errorWidget: const Center(
                          child: Icon(
                            Icons.person,
                            size: 60, // Reducido de 90 a 60
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: 60, // Reducido de 90 a 60
                          color: Colors.white70,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Username and follow button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display actual username from Spotify
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: CorporativeColors.whiteColor,
                  ),
                ),
                
                const SizedBox(width: 16),
                  // Follow button
                SizedBox(
                  width: 90,
                  height: 30,
                  child: ElevatedButton(                    
                    onPressed: _isFollowActionLoading ? null : () async {
                      // Mostramos el estado de carga específico para el botón
                      setState(() {
                        _isFollowActionLoading = true;
                      });
                      
                      try {
                        // Optimistic UI update - actualizamos la UI inmediatamente
                        bool previousState = _isFollowing;
                        
                        // Actualizar el estado de inmediato para una respuesta instantánea
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                        
                        bool success;
                        if (previousState) {
                          // Dejar de seguir al usuario
                          debugPrint("[DEBUG] Unfollowing user: ${widget.userId}");
                          success = await _profileService.unfollowUser(widget.userId);
                          
                          if (!success && mounted) {
                            // Si falla, revertimos al estado anterior
                            setState(() {
                              _isFollowing = true;
                            });
                            
                            // Mostramos mensaje de error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al dejar de seguir a ${user.displayName}'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            debugPrint("[DEBUG] Successfully unfollowed user");
                          }
                        } else {
                          // Seguir al usuario
                          debugPrint("[DEBUG] Following user: ${widget.userId}");
                          success = await _profileService.followUser(widget.userId);
                          
                          if (!success && mounted) {
                            // Si falla, revertimos al estado anterior
                            setState(() {
                              _isFollowing = false;
                            });
                            
                            // Mostramos mensaje de error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al seguir a ${user.displayName}'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            debugPrint("[DEBUG] Successfully followed user");
                          }
                        }
                        
                        // Verificamos el estado actual después de la operación 
                        // para asegurarnos de que la UI esté sincronizada con el servidor
                        if (success) {
                          final currentFollowStatus = await _profileService.isFollowing(widget.userId);
                          if (mounted && currentFollowStatus != _isFollowing) {
                            setState(() {
                              _isFollowing = currentFollowStatus;
                              debugPrint("[DEBUG] Updated follow status from server: $_isFollowing");
                            });
                          }
                        }
                      } catch (e) {
                        debugPrint("[ERROR] Error updating follow status: $e");
                        // Mostramos mensaje de error genérico
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al actualizar el estado de seguimiento'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }                      } finally {
                        // Terminamos el estado de carga específico para el botón
                        if (mounted) {
                          setState(() {
                            _isFollowActionLoading = false;
                          });
                        }
                      }
                    },                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing 
                          ? Colors.black 
                          : CorporativeColors.whiteColor,
                      foregroundColor: _isFollowing 
                          ? CorporativeColors.whiteColor 
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _isFollowing 
                              ? CorporativeColors.mainColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      // Deshabilitar el botón mientras carga
                      disabledBackgroundColor: Colors.grey[800],
                      disabledForegroundColor: Colors.grey[500],
                    ),
                    child: _isFollowActionLoading
                      ? const SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            color: CorporativeColors.mainColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isFollowing ? 'Unfollow' : 'Follow',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Open in Spotify button with actual profile URL
            OpenSpotifyButton(
              spotifyUrl: user.spotifyUrl,
              height: 30,
              text: 'Open in Spotify',
            ),
            
            const SizedBox(height: 15),
              // Star of the Day and Compatibility section
            SizedBox(
              height: 255, // Altura aumentada para acomodar los títulos externos
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 7,
                      child: starTrack != null ? StarOfTheDay(
                        albumCoverUrl: starTrack.imageUrl ?? '',
                        artistName: starTrack.artistName,
                        songName: starTrack.name,
                        spotifyUrl: starTrack.spotifyUrl,
                        title: "Top Rated Track",
                        ) : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título externo
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              "Top Rated Track",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: CorporativeColors.mainColor,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Center(
                                child: Text(
                                  "No rated tracks available",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 5,
                      child: UserCompatibility(
                        compatibilityPercentage: _profileService.calculateCompatibility().toInt(),
                        subtitle: 'Average Rating',
                        description: 'Based on ratings',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
            // Ratings section (mostrando como álbumes)
            topAlbums.isNotEmpty ? TopFiveAlbums(
              albums: topAlbums,
              title: 'Recent Ratings',
            ) : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título fuera del contenedor
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    "Recent Ratings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Contenedor cuando no hay datos
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CorporativeColors.mainColor,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "No ratings available",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
    // Se han eliminado los métodos de placeholder para la carga
}