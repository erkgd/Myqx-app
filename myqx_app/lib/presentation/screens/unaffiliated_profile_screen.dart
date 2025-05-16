import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/unaffiliated_profile_service.dart';
import 'package:myqx_app/core/storage/secure_storage.dart';
import 'package:myqx_app/presentation/widgets/profile/follow_button.dart';
import 'package:myqx_app/presentation/widgets/profile/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/profile/top_five_albums.dart';
import 'package:myqx_app/presentation/widgets/profile/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/general/lazy_image.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';

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
  bool _isFollowStatusLoaded = false; // Nueva variable para controlar si el estado de seguimiento se ha cargado
  late final UnaffiliatedProfileService _profileService;
  final SecureStorage _secureStorage = SecureStorage();
    @override
  void initState() {
    super.initState();
    
    // Inicializar el servicio y configurar listeners
    _profileService = UnaffiliatedProfileService();
    _profileService.addListener(() => mounted ? setState(() {}) : null);
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar datos de perfil
    _loadProfile();
  }
  
  @override
  void dispose() {
    _profileService.removeListener(() => mounted ? setState(() {}) : null);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  /// Carga todos los datos del perfil de forma optimizada
  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // Verificar autenticación y cargar perfil
      final isAuthenticated = await _secureStorage.isAuthenticated();
      await _profileService.loadProfileById(widget.userId);
      
      // Cargar estado de seguimiento si está autenticado
      if (isAuthenticated) {
        await _loadFollowingStatus();
      }
    } catch (e) {
      debugPrint("[ERROR] Error cargando perfil: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }  /// Verifica si el usuario actual está siguiendo al perfil visualizado
  Future<void> _loadFollowingStatus() async {
    try {
      final currentUserId = await _secureStorage.getUserId();
      
      // No se puede seguir a uno mismo
      if (currentUserId == widget.userId) {
        if (mounted) {
          setState(() => _isFollowStatusLoaded = true); // Marcar como cargado incluso si es uno mismo
        }
        return;
      }
      
      // Evitar cualquier caché añadiendo un timestamp a la petición
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Actualizar estado de seguimiento desde API
      final isFollowing = await _profileService.isFollowing(widget.userId);
      
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isFollowStatusLoaded = true; // Marcar que el estado de seguimiento se ha cargado
        });
        debugPrint("[DEBUG] Estado de seguimiento actualizado: ${_isFollowing ? 'Following' : 'Not following'}");
      }
    } catch (e) {
      debugPrint("[ERROR] Error al verificar estado de seguimiento: $e");
      if (mounted) {
        setState(() => _isFollowStatusLoaded = true); // Marcar como cargado incluso en caso de error
      }
    }
  }
  
  // Método para recargar solo el estado de seguimiento (puede ser llamado después de un cambio)
  Future<void> _refreshFollowingStatus() async {
    try {
      final isFollowing = await _profileService.isFollowing(widget.userId);
      
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
        debugPrint("[DEBUG] Estado de seguimiento refrescado: ${_isFollowing ? 'Following' : 'Not following'}");
      }
    } catch (e) {
      debugPrint("[ERROR] Error al refrescar estado de seguimiento: $e");
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
  }    Widget _buildBody() {
    // Si el servicio está cargando pero tenemos datos en caché, mostrar contenido con indicador
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
      // Simplemente mostrar el contenido principal sin el botón de recarga
      return _buildProfileContent();
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
          const SizedBox(height: 24),          ElevatedButton(
            onPressed: _loadProfile,
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
              onPressed: _loadProfile,
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
              children: [                // Display actual username from Spotify
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: CorporativeColors.whiteColor,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Debug para verificar valores nulos
                Builder(builder: (context) {
                  debugPrint("[DEBUG] FollowButton params - userId: ${user.id}, displayName: ${user.displayName}, isFollowing: $_isFollowing, profileService: ${_profileService != null ? 'not null' : 'null'}");
                  
                  // Follow button
                  if (user.id.isNotEmpty && _profileService != null) {
                    return FollowButton(
                      userId: user.id,
                      displayName: user.displayName,
                      isFollowing: _isFollowing,
                      profileService: _profileService,
                    );
                  } else {
                    // Botón de seguimiento fallback si hay datos faltantes
                    return ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Unavailable', style: TextStyle(fontSize: 12)),
                    );
                  }
                }),
              ],
            ),
              const SizedBox(height: 10),
            
            // Open in Spotify button with actual profile URL - centered
            Center(
              child: OpenSpotifyButton(
                spotifyUrl: user.spotifyUrl,
                height: 30,
                text: 'Open in Spotify',
              ),
            ),
            
            const SizedBox(height: 20),
              // Star of the Day and Compatibility section
            SizedBox(
              height: 255, // Altura aumentada para acomodar los títulos externos
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [                    Expanded(
                      flex: 7,
                      child: starTrack != null ? StarOfTheDay(
                        albumCoverUrl: starTrack.imageUrl ?? '',
                        artistName: starTrack.artistName,
                        songName: starTrack.name,
                        spotifyUrl: starTrack.spotifyUrl,
                      ) : MusicContainer(
                        borderColor: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título interno
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0, bottom: 8.0),
                              child: Text(
                                "Activity",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Contenido centrado con mensaje
                            Expanded(
                              child: Center(
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
                          ],
                        ),
                      ),                    ),
                    
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 8, 20, 5),
                        child: UserCompatibility(
                          compatibilityPercentage: _profileService.calculateCompatibility().toInt(),
                          subtitle: 'Average Rating',
                          description: 'Based on ratings',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Ratings section (mostrando como álbumes)            
            topAlbums.isNotEmpty ? TopFiveAlbums(
              albums: topAlbums,
              title: 'Activity',
            ) : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título fuera del contenedor
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(                    
                    "Activity",
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
  // Los métodos _buildFollowButton y _toggleFollowStatus han sido eliminados
  // y su funcionalidad transferida al widget FollowButton

}