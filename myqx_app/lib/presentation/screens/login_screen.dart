import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/auth/spotify_login_button.dart';
import 'package:myqx_app/core/constants/navbar_routes.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';
// Convierte a StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Crea la clase State e implementa WidgetsBindingObserver
class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // Opcional: Implementa didChangeAppLifecycleState para detectar cuando la app va a 
  // segundo plano y vuelve al primer plano, lo cual es útil para manejar el flujo de OAuth
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Puedes usar esto para manejar el regreso desde el navegador
    if (state == AppLifecycleState.resumed) {
      debugPrint('[DEBUG] App regresó al primer plano');
      // Aquí podrías verificar si hay autenticación pendiente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              CorporativeColors.mainColor.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo o título de la app
                    const Text(
                      'MyQx',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtítulo o eslogan
                    const Text(
                      'Discover your music compatibility',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Botón de inicio de sesión con Spotify
                    SpotifyLoginButton(
                      onLoginSuccess: () {
                        debugPrint('[DEBUG] Login success callback triggered - navigating to AppScaffold');
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => 
                              AppScaffold(
                                
                              ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      onLoginFailed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to connect with Spotify. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Texto informativo sobre el uso de Spotify
                    const Text(
                      'By connecting, you agree to share your Spotify data with MyQx. We only access your music preferences to provide our service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}