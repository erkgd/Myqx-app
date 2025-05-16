import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/providers/auth_provider.dart';

class SpotifyLoginButton extends StatelessWidget {
  final Function? onLoginSuccess;
  final Function? onLoginFailed;
  
  const SpotifyLoginButton({
    Key? key,
    this.onLoginSuccess,
    this.onLoginFailed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final spotifyAuthService = SpotifyAuthService();
    
    return ValueListenableBuilder<bool>(
      valueListenable: spotifyAuthService.isLoading,
      builder: (context, isLoading, child) {
        return ElevatedButton.icon(
          onPressed: isLoading 
              ? null 
              : () async {
                  try {
                    debugPrint('[DEBUG] Iniciando proceso de login con Spotify desde componente');
                    
                    // Limpiamos cualquier error anterior
                    authService.errorMessage.value = null;
                    
                    // Verificar si hay un token persistente que pueda estar causando problemas
                    final hasToken = await authService.hasStoredToken();
                    if (hasToken) {
                      debugPrint('[DEBUG] SpotifyLoginButton: Se encontró un token persistente, limpiándolo antes de iniciar sesión');
                      await authService.forceCleanAuthState();
                    }
                    
                    // Usar el authService del Provider para el login con Spotify
                    final success = await authService.loginWithSpotify();

                    if (success) {
                      debugPrint('[DEBUG] Login con Spotify exitoso desde componente');
                      
                      // Esperar un momento para asegurar que el estado se actualiza
                      await Future.delayed(const Duration(milliseconds: 300));
                      
                      if (context.mounted && onLoginSuccess != null) {
                        onLoginSuccess!();
                      }
                      
                      // Doble verificación del estado de autenticación
                      if (!authService.isAuthenticated.value) {
                        debugPrint('[DEBUG] Forzando actualización del estado de autenticación después de login exitoso');
                        authService.isAuthenticated.value = true;
                        authService.notifyListeners();
                      }
                    } else {
                      debugPrint('[DEBUG] Login con Spotify falló desde componente');
                      if (onLoginFailed != null) {
                        onLoginFailed!();
                      }
                    }
                  } catch (e) {
                    debugPrint('[ERROR] Error en login con Spotify: $e');
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al conectar con Spotify: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      
                      if (onLoginFailed != null) {
                        onLoginFailed!();
                      }
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.4),
            foregroundColor: const Color(0xFF1DB954),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: isLoading 
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                    strokeWidth: 2,
                  ),
                )
              : SvgPicture.asset(
                  'assets/images/spotifyLogo.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1DB954),
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (context) => const Icon(
                    Icons.music_note,
                    color: Color(0xFF1DB954),
                  ),
                ),
          label: Text(
            isLoading ? 'CONNECTING...' : 'CONTINUE WITH SPOTIFY',
            style: const TextStyle(
              color: Color(0xFF1DB954),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}