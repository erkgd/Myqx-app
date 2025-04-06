import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/providers/auth_provider.dart';
import 'package:myqx_app/presentation/widgets/general/loading_overlay.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';
import 'package:myqx_app/presentation/widgets/auth/spotify_login_button.dart';

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
    if (state == AppLifecycleState.resumed) {
      debugPrint('[DEBUG] App returned to foreground');
      _checkPendingAuthentication();
    }
  }

  void _checkPendingAuthentication() async {
    debugPrint('[DEBUG] Verificando si hay una autenticación pendiente...');
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final hasToken = await authService.hasStoredToken();
      final isAuthenticated = authService.isAuthenticated.value;

      debugPrint('[DEBUG] Estado de autenticación: ${isAuthenticated ? "Autenticado" : "No autenticado"}');
      debugPrint('[DEBUG] Token almacenado: ${hasToken ? "Existe" : "No existe"}');

      if (hasToken && !isAuthenticated) {
        debugPrint('[DEBUG] Detectado posible proceso OAuth pendiente, verificando...');
        final isValid = await authService.verifyToken();
        if (isValid) {
          debugPrint('[DEBUG] Token verificado exitosamente después de OAuth');
          authService.isAuthenticated.value = true;
          authService.notifyListeners();
          if (mounted) {
            setState(() {});
          }
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!authService.isAuthenticated.value && mounted) {
              debugPrint('[DEBUG] Forzando actualización del estado de autenticación');
              authService.isAuthenticated.value = true;
              authService.notifyListeners();
              setState(() {});
            }
          });
        } else {
          debugPrint('[DEBUG] Token no válido después de OAuth, limpiando estado');
          await authService.forceCleanAuthState();
        }
      } else if (hasToken) {
        debugPrint('[DEBUG] Verificando validez del token existente...');
        final isValid = await authService.verifyToken();
        if (!isValid) {
          debugPrint('[DEBUG] Token existente no es válido, limpiando estado');
          await authService.forceCleanAuthState();
        } else if (!isAuthenticated) {
          debugPrint('[DEBUG] Token válido pero no autenticado, actualizando estado');
          authService.isAuthenticated.value = true;
          authService.notifyListeners();
        }
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('[DEBUG] Error al verificar autenticación pendiente: $e');
      await authService.forceCleanAuthState();
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      debugPrint('[DEBUG] Login: Intentando iniciar sesión con username: ${_usernameController.text.trim()}');
      final hasToken = await authService.hasStoredToken();
      debugPrint('[DEBUG] Login: Estado del token antes de iniciar sesión: ${hasToken ? "Existe" : "No existe"}');

      if (hasToken) {
        debugPrint('[DEBUG] Login: Se encontró un token persistente, limpiándolo antes de iniciar sesión');
        await authService.logout();
      }

      final result = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result == null) {
        debugPrint('[DEBUG] Login: Falló el inicio de sesión');
        setState(() {
          _errorMessage = authService.errorMessage.value ??
              'Login error. Please verify your credentials.';
        });
      } else {
        debugPrint('[DEBUG] Login: Inicio de sesión exitoso');
      }
    } catch (e) {
      debugPrint('[DEBUG] Login: Excepción en el proceso de login: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
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
                    const Text(
                      'Discover your music compatibility',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 60),
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
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(27),
                        border: Border.all(color: const Color(0xFF1DB954), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(27),
                        child: SpotifyLoginButton(
                          onLoginSuccess: () {
                            debugPrint('[DEBUG] Login con Spotify exitoso desde el componente');
                          },
                          onLoginFailed: () {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            _showError(authService.errorMessage.value ??
                                'Error al iniciar sesión con Spotify.');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'By connecting, you agree to share your Spotify data with MyQx. We only access your music preferences to provide our service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 40),
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