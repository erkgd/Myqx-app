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

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
  bool _isInitializing = true; // Estado para la carga inicial

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
    
    // Verificar el estado inicial con el servidor
    _verifyInitialFollowingStatus();
  }
  
  /// Método para verificar el estado inicial de seguimiento
  Future<void> _verifyInitialFollowingStatus() async {
    try {
      final serverStatus = await widget.profileService.isFollowing(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = serverStatus;
          _isInitializing = false; // Ya tenemos respuesta del servidor
        });
        debugPrint("[DEBUG] Initial server follow status: $_isFollowing");
      }
    } catch (e) {
      debugPrint("[ERROR] Error verificando estado inicial: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false; // Aunque falle, permitimos mostrar el botón
        });
      }
    }
  }

  @override
  void didUpdateWidget(FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowing != widget.isFollowing) {
      setState(() {
        _isFollowing = widget.isFollowing;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 30,
      child: ElevatedButton(
        // Solo deshabilitamos el botón durante la inicialización, no durante las operaciones (UI optimista)
        onPressed: _isInitializing ? null : _toggleFollowStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? Colors.black : CorporativeColors.whiteColor,
          foregroundColor: _isFollowing ? CorporativeColors.whiteColor : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _isFollowing ? CorporativeColors.mainColor : Colors.transparent,
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // Color de fondo más claro durante la inicialización
          disabledBackgroundColor: Colors.grey[800],
          disabledForegroundColor: Colors.grey,
        ),
        child: _isInitializing
          ? const SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(color: CorporativeColors.mainColor, strokeWidth: 2),
            )
          : Text(
              _isFollowing ? 'Unfollow' : 'Follow',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
      ),
    );
  }
  /// Alterna el estado de seguimiento del usuario
  Future<void> _toggleFollowStatus() async {
    // No activamos estado de carga para implementar UI optimista
    // (el botón responde inmediatamente sin mostrar indicador de carga)
    
    try {
      // Optimistic UI update - actualizamos la UI inmediatamente 
      bool previousState = _isFollowing;
      
      // Actualizar el estado de inmediato para una respuesta instantánea
      setState(() {
        _isFollowing = !_isFollowing;
      });
      
      bool success;
      if (previousState) {        // Dejar de seguir al usuario
        debugPrint("[DEBUG] Unfollowing user: ${widget.userId}");
        success = await widget.profileService.unfollowUser(widget.userId);
        debugPrint("[DEBUG] Unfollow operation result: $success");
        
        if (!success && mounted) {
          // Si falla, revertimos al estado anterior
          setState(() {
            _isFollowing = true;
          });
          
          // Mostramos mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al dejar de seguir a ${widget.displayName}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          debugPrint("[DEBUG] Successfully unfollowed user: ${widget.displayName}");
        }
      } else {        // Seguir al usuario
        debugPrint("[DEBUG] Following user: ${widget.userId}");
        success = await widget.profileService.followUser(widget.userId);
        debugPrint("[DEBUG] Follow operation result: $success");
        
        if (!success && mounted) {
          // Si falla, revertimos al estado anterior
          setState(() {
            _isFollowing = false;
          });
          
          // Mostramos mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al seguir a ${widget.displayName}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          debugPrint("[DEBUG] Successfully followed user: ${widget.displayName}");
        }
      }
        // Solo verificamos el estado si la operación no tuvo éxito
      // Si fue exitosa, confiamos en nuestro estado optimista
      if (!success) { 
        // Hay una discrepancia, verificar con el servidor
        debugPrint("[DEBUG] Verificando estado real con el servidor tras operación fallida");
        final currentFollowStatus = await widget.profileService.isFollowing(widget.userId);
        
        if (mounted && currentFollowStatus != _isFollowing) {
          // Solo actualizar si hay discrepancia
          setState(() {
            debugPrint("[DEBUG] Corrigiendo estado de seguimiento: $_isFollowing -> $currentFollowStatus");
            _isFollowing = currentFollowStatus;
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
      }    } finally {
      // No necesitamos finalizar ningún estado de carga ya que implementamos UI optimista
    }
  }
}
