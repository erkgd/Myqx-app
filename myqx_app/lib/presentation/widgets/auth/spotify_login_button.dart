import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';
import 'package:myqx_app/core/constants/navbar_routes.dart';

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
    final authService = SpotifyAuthService();
    
    return ValueListenableBuilder<bool>(
      valueListenable: authService.isLoading,
      builder: (context, isLoading, child) {
        return ElevatedButton(
          onPressed: isLoading 
              ? null 
              : () async {
                  try {
                    final success = await authService.login();

                    if (success) {
                      debugPrint('[DEBUG] Login successful - navigating to profile');
                      
                      // Longer delay to ensure state updates
                      await Future.delayed(const Duration(milliseconds: 300));
                      
                      // Use a more direct approach to navigation
                      if (context.mounted) {
                        if (onLoginSuccess != null) {
                          onLoginSuccess!();
                        } else {
                          // Force navigation regardless of ValueListenable state
                          debugPrint('[DEBUG] Using direct navigation to AppScaffold');
                          
                          // Clear navigation stack completely and add new page
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => AppScaffold(pages: NavbarRoutes.pages),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        }
                      }
                    } else {
                      debugPrint('[DEBUG] Login failed');
                      if (onLoginFailed != null) {
                        onLoginFailed!();
                      }
                    }
                  } catch (e) {
                    debugPrint('[ERROR] During login/navigation: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: CorporativeColors.spotifyColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: isLoading 
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_White.png',
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Connect with Spotify'),
                  ],
                ),
        );
      },
    );
  }
}