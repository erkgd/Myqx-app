import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/providers/auth_provider.dart';
import 'package:myqx_app/presentation/widgets/general/loading_overlay.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Manejar el regreso desde el navegador en caso de OAuth
    if (state == AppLifecycleState.resumed) {
      debugPrint('[DEBUG] App returned to foreground');
      // Aquí podrías verificar si hay una autenticación pendiente
      _checkPendingAuthentication();
    }
  }
  
  void _checkPendingAuthentication() {
    // Verificar si hay un proceso de autenticación pendiente
    final authService = Provider.of<AuthService>(context, listen: false);
    // Implementación depende de cómo manejas el estado de autenticación pendiente
  }

  // Handler for standard login with username and password
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      final result = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      
      if (result == null) {
        setState(() {
          _errorMessage = authService.errorMessage.value ?? 
                         'Login error. Please verify your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Handler for Spotify login
  Future<void> _handleSpotifyLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      debugPrint('[DEBUG] Starting Spotify login process');
      final success = await authService.loginWithSpotify();
      
      if (success) {
        debugPrint('[DEBUG] Spotify login successful');
      } else {
        debugPrint('[DEBUG] Spotify login failed');
        setState(() {
          _errorMessage = authService.errorMessage.value ?? 
                         'Error signing in with Spotify.';
        });
      }
    } catch (e) {
      debugPrint('[DEBUG] Exception during Spotify login: ${e.toString()}');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        child: LoadingOverlay(
          isLoading: _isLoading,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    const Text(
                      'MyQx',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    const Text(
                      'Discover your music compatibility',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Spotify login button - styled as in the new design
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(27), // More rounded
                        border: Border.all(color: const Color(0xFF1DB954), width: 1),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _handleSpotifyLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          foregroundColor: const Color(0xFF1DB954),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/spotifyLogo.svg',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.music_note, color: Color(0xFF1DB954));
                          },
                        ),
                        label: const Text(
                          'CONTINUE WITH SPOTIFY',
                          style: TextStyle(
                            color: Color(0xFF1DB954),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
                    
                    const SizedBox(height: 40),
                    
                    // OR Separator
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white30)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: Colors.white54)),
                        ),
                        Expanded(child: Divider(color: Colors.white30)),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Login form
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CorporativeColors.mainColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username or email',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.person, color: CorporativeColors.mainColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[700]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: CorporativeColors.mainColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red[400]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your username or email';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.lock, color: CorporativeColors.mainColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[700]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: CorporativeColors.mainColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red[400]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                              ),
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                            const SizedBox(height: 24),
                            
                            // Login button
                            ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CorporativeColors.mainColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Registration link
                    TextButton(
                      onPressed: () {
                        // Navigate to registration screen
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(color: Colors.grey[300]),
                        textAlign: TextAlign.center,
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