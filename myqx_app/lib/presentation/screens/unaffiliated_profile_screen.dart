import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/unaffiliated_profile_service.dart';
import 'package:myqx_app/core/services/performance_service.dart';
import 'package:myqx_app/presentation/widgets/profile/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/profile/top_five_albums.dart';
import 'package:myqx_app/presentation/widgets/profile/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/general/lazy_image.dart';
import 'package:myqx_app/presentation/widgets/general/skeleton_loading.dart';

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
    // Track loading states for different profile sections
  bool _userDataLoaded = false;
  bool _compatibilityLoaded = false;
  bool _starOfDayLoaded = false;
  bool _topAlbumsLoaded = false;
  
  // Progressive loading timeouts for simulation (would be real API calls)
  final Duration _compatibilityLoadTime = const Duration(milliseconds: 500);
  final Duration _starLoadTime = const Duration(milliseconds: 1200);
  final Duration _albumsLoadTime = const Duration(milliseconds: 2000);
  
  late final UnaffiliatedProfileService _profileService;
  final PerformanceService _performanceService = PerformanceService();
  @override
  void initState() {
    super.initState();
    
    // Inicializar el servicio con las dependencias necesarias
    _profileService = UnaffiliatedProfileService();
    
    // Registrar observer para ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar datos del perfil inmediatamente al abrir la pantalla
    _loadProfileDataProgressive();
  }
  
  @override
  void dispose() {
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
      
      // Step 1: Load basic user data (highest priority)
      await _profileService.loadProfileById(widget.userId);
      
      if (mounted) {
        setState(() {
          // We can show the UI now with the user data loaded
          _isLoading = false;
        });
      }
      
      // Step 2: Check following status in parallel with other data
      _loadFollowingStatus();
      
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
      
      // Step 1: Load basic user data (highest priority)
      await _profileService.loadProfileById(widget.userId);
      
      // Step 2: Check following status
      await _loadFollowingStatus();
      
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
      final isFollowing = await _profileService.isFollowing(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
      debugPrint("[DEBUG] Following status: ${_isFollowing ? 'Following' : 'Not following'}");
    } catch (e) {
      debugPrint("[ERROR] Error checking follow status: $e");
    }
  }

  
  Future<void> _loadCompatibilityData() async {
    try {
      // This would be a separate API call or calculation
      // Here we're simulating with a delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (mounted) {
        setState(() {
          _compatibilityLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load compatibility data: $e");
    }
  }
  
  Future<void> _loadStarOfDayData() async {
    try {
      // Simulating a separate API call for star of the day
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() {
          _starOfDayLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load star of the day: $e");
    }
  }
  
  Future<void> _loadTopAlbumsData() async {
    try {
      // Simulating a separate API call for top albums
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (mounted) {
        setState(() {
          _topAlbumsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("[ERROR] Failed to load top albums: $e");
    }
  }
  
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
      return _buildSkeletonLoading();
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
  
  Widget _buildSkeletonLoading() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Skeleton para la información del usuario
        Row(
          children: [
            const SkeletonLoading(width: 80, height: 80, shape: BoxShape.circle),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLoading(width: 150, height: 24),
                  SizedBox(height: 8),
                  SkeletonLoading(width: 100, height: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Skeleton para el botón de seguimiento
        const Center(child: SkeletonLoading(width: 120, height: 40)),
        const SizedBox(height: 32),
        
        // Skeleton para la compatibilidad
        const SkeletonLoading(width: double.infinity, height: 80),
        const SizedBox(height: 24),
        
        // Skeleton para la canción destacada
        const SkeletonLoading(width: double.infinity, height: 140),
        const SizedBox(height: 24),
        
        // Skeleton para los álbumes
        const SkeletonLoading(width: double.infinity, height: 200),
      ],
    );
  }
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
            const SizedBox(height: 5),
              // Profile circle with optimized image loading
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CorporativeColors.mainColor,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? LazyImage(
                        imageUrl: imageUrl,
                        width: 160,
                        height: 160,
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
                            size: 90,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: 90,
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
                  child: ElevatedButton(                    onPressed: _isFollowActionLoading ? null : () async {
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
            
            // Star of the Day and Compatibility
            SizedBox(
              height: 255,
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
                        ) : Container(
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
                            "No star track available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 5,
                      child: UserCompatibility(
                        compatibilityPercentage: _profileService.calculateCompatibility().toInt(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
              // Top 5 albums section with actual data
            topAlbums.isNotEmpty ? TopFiveAlbums(
              albums: topAlbums,
              title: 'Top Albums',
            ) : Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CorporativeColors.mainColor,
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  "No album data available",
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
      ),
    );
  }
  
  // Loading section placeholders
  Widget _buildCompatibilityLoadingSection() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(CorporativeColors.mainColor),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSongLoadingSection() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 18.0,
                  margin: const EdgeInsets.only(bottom: 8.0, right: 50.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Container(
                  width: 120.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                const CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(CorporativeColors.mainColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
    );
  }
  
  Widget _buildAlbumsLoadingSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title placeholder
          Container(
            width: 160,
            height: 20.0,
            margin: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          
          // Album covers placeholders
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}