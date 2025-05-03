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
    this.profileImageUrl,
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
  
  @override
  void initState() {
    super.initState();
    _profileService = UnaffiliatedProfileService();
    
    // Registrar observer
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar datos
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
      
      // Step 1: Cargar datos del perfil directamente desde la API /api/profile/{userId}
      final bool success = await _profileService.loadProfileFromBff(widget.userId);
      
      if (!success) {
        // Si falla la carga desde la API de perfil, intentamos con el método tradicional como fallback
        debugPrint("[DEBUG] Profile: API de perfil falló, intentando método alternativo");
        await _profileService.loadProfileById(widget.userId);
      }
      
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(CorporativeColors.mainColor),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      return _buildErrorState();
    }
  }
}
