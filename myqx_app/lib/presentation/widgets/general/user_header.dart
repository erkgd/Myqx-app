import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/general/divisor.dart';
import 'package:myqx_app/presentation/widgets/spotify/user_circle.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_profile_service.dart';
import 'package:myqx_app/data/models/spotify_models.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
class UserHeader extends StatefulWidget implements PreferredSizeWidget {
  final String? imageUrl;
  final String? username;
  final bool showCircle; 

  const UserHeader({
    super.key, 
    this.imageUrl,
    this.username,
    this.showCircle = false,
  });
  
  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  late final SpotifyProfileService _profileService;
  SpotifyUser? _user;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _profileService = SpotifyProfileService();
    
    // Obtener datos iniciales que podrían venir de SharedPreferences
    _user = _profileService.currentUser;
    
    // Si no hay usuario, intentar obtenerlo (primero de SharedPreferences y luego de API)
    if (_user == null) {
      _loadUserData();
    }
    
    // Suscribirse a cambios en el servicio para actualizar la UI
    _profileService.addListener(_onProfileChanged);
  }
  
  void _onProfileChanged() {
    if (mounted) {
      setState(() {
        _user = _profileService.currentUser;
        _isLoading = _profileService.isLoading;
      });
    }
  }
  
  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  // Método optimizado para cargar datos de usuario
  Future<void> _loadUserData() async {
    if (_profileService.currentUser == null && !_profileService.isLoading) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // initialize() primero intentará cargar desde SharedPreferences
        await _profileService.initialize();
        
        if (mounted) {
          setState(() {
            _user = _profileService.currentUser;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error loading user data: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar datos proporcionados o datos del usuario autenticado
    final displayName = widget.username ?? _user?.displayName ?? 'User';
    final userImageUrl = widget.imageUrl ?? _user?.imageUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8.0),
          child: AppBar(
            toolbarHeight: 70.0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28.0),
                onPressed: () {
                  final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                  navProvider.setCurrentIndex(3); // Usando el nuevo método para ir a la pantalla de búsqueda
                },
              ),
            ),
            title: const SizedBox(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 8.0),
                child: GestureDetector(
                  onTap: () {
                    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                    navProvider.setCurrentIndex(0);
                  },
                  child: _isLoading
                      ? _buildLoadingAvatar()
                      : UserCircle(
                          username: displayName,
                          imageUrl: userImageUrl ?? '',
                          imageSize: 36.0,
                          fontSize: 14.0,
                        ),
                ),
              ),
            ],
            centerTitle: true,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divisor(),
            ),
          ),
        ),
        
        // Botón +
        if (widget.showCircle)
          Positioned(
            left: 0,
            right: 0,
            bottom: -2,
            child: Center(
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CorporativeColors.gradientColorTop,
                  border: Border.all(
                    color: CorporativeColors.mainColor,
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.add,
                    color: CorporativeColors.mainColor,
                    size: 35.0,
                  ),
                  onPressed: () {
                    // Acción del botón más
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // Widget para mostrar mientras se carga el avatar
  Widget _buildLoadingAvatar() {
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CorporativeColors.mainColor,
          width: 2.0,
        ),
        color: Colors.transparent,
      ),
      child: const Center(
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            color: CorporativeColors.mainColor,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }
}