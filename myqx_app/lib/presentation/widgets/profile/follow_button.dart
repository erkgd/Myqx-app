import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/unaffiliated_profile_service.dart';

/// Widget de botón de seguimiento reutilizable
class FollowButton extends StatefulWidget {
  final String userId;
  final String displayName;
  final bool isFollowing;
  final UnaffiliatedProfileService profileService;

  const FollowButton({
    Key? key,
    required this.userId,
    required this.displayName,
    required this.isFollowing,
    required this.profileService,
  }) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> with SingleTickerProviderStateMixin {
  late bool _isFollowing;
  bool _isLoading = false;
  bool _isInitializing = true; // Estado para verificar si tenemos respuesta del servidor
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
    
    // Configurar la animación de fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn)
    );
    
    // Verificar el estado inicial con el servidor
    _verifyFollowingStatus();
  }
  
  // Método para verificar el estado de seguimiento con el servidor
  Future<void> _verifyFollowingStatus() async {
    try {
      final serverStatus = await widget.profileService.isFollowing(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = serverStatus;
          _isInitializing = false; // Ya tenemos respuesta del servidor
          _fadeController.forward(); // Iniciar animación fade-in
        });
        debugPrint("[DEBUG] Initial server follow status: $_isFollowing");
      }
    } catch (e) {
      debugPrint("[ERROR] Error verificando estado inicial: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false; // Aunque falle, permitimos mostrar el botón
          _fadeController.forward();
        });
      }
    }
  }
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si no estamos en estado de carga y hay un cambio real
    if (oldWidget.isFollowing != widget.isFollowing && !_isInitializing) {
      setState(() {
        _isFollowing = widget.isFollowing;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // Siempre mostramos el botón, pero con diferentes estados
    return AnimatedOpacity(
      opacity: _isInitializing ? 0.7 : 1.0, // Botón con opacidad reducida durante inicialización
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: 90,
        height: 30,
        child: ElevatedButton(
          // Botón deshabilitado durante inicialización o carga
          onPressed: (_isInitializing || _isLoading) ? null : _toggleFollowStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? Colors.black : CorporativeColors.whiteColor,
            foregroundColor: _isFollowing ? CorporativeColors.whiteColor : Colors.black,
            // Durante la inicialización, usar un borde más claro
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: _isInitializing 
                    ? Colors.grey
                    : _isFollowing 
                        ? CorporativeColors.mainColor 
                        : Colors.transparent,
                width: 1,
              ),
            ),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            // Color de fondo más claro durante la inicialización
            disabledBackgroundColor: _isInitializing 
                ? Colors.grey[800] 
                : _isFollowing 
                    ? Colors.black.withOpacity(0.7) 
                    : CorporativeColors.whiteColor.withOpacity(0.7),
            disabledForegroundColor: Colors.grey,
          ),
          child: _isInitializing || _isLoading
            // Mostrar indicador de carga dentro del botón
            ? const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(
                  color: CorporativeColors.mainColor,
                  strokeWidth: 2,
                ),
              )
            // Mostrar el texto normal cuando está listo
            : Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
        ),
      ),
    );
  }
  /// Alterna el estado de seguimiento del usuario
  Future<void> _toggleFollowStatus() async {
    if (_isLoading) return; // Evitar múltiples clics
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Guardar estado anterior para poder revertirlo en caso de error
      bool previousState = _isFollowing;
      bool actionSuccess = false;
      
      // No actualizamos el estado visual hasta confirmar con el servidor
      if (previousState) {
        // Intentar dejar de seguir al usuario
        debugPrint("[DEBUG] Intentando unfollow para usuario: ${widget.userId}");
        actionSuccess = await widget.profileService.unfollowUser(widget.userId);
        
        if (actionSuccess) {
          debugPrint("[DEBUG] Unfollow exitoso confirmado por servidor");
          if (mounted) {
            setState(() {
              _isFollowing = false;
            });
          }
        } else {
          // La operación falló
          debugPrint("[ERROR] Unfollow falló según respuesta del servidor");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se pudo dejar de seguir a ${widget.displayName}'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Intentar seguir al usuario
        debugPrint("[DEBUG] Intentando follow para usuario: ${widget.userId}");
        actionSuccess = await widget.profileService.followUser(widget.userId);
        
        if (actionSuccess) {
          debugPrint("[DEBUG] Follow exitoso confirmado por servidor");
          if (mounted) {
            setState(() {
              _isFollowing = true;
            });
          }
        } else {
          // La operación falló
          debugPrint("[ERROR] Follow falló según respuesta del servidor");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se pudo seguir a ${widget.displayName}'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      
      // Siempre verificar el estado actual con el servidor después de la operación
      // para asegurar que la UI esté sincronizada
      try {
        final serverStatus = await widget.profileService.isFollowing(widget.userId);
        if (mounted && serverStatus != _isFollowing) {
          setState(() {
            _isFollowing = serverStatus;
            debugPrint("[DEBUG] Estado actualizado desde servidor: $_isFollowing");
          });
        }
      } catch (statusError) {
        // Si hay un error verificando el estado, no hacer nada
        debugPrint("[WARNING] No se pudo verificar el estado final: $statusError");
      }
      
    } catch (e) {
      debugPrint("[ERROR] Error no manejado en toggle follow: $e");
      // Mostrar error genérico
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el estado de seguimiento'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Siempre terminar el estado de carga
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
