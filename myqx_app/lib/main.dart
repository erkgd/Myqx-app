import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:myqx_app/presentation/providers/auth_provider.dart';
import 'package:myqx_app/presentation/providers/spotify_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';
import 'package:myqx_app/presentation/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SpotifyAuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myqx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CorporativeColors.mainColor),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Widget que determina qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _initialCheckDone = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Verificar el estado de autenticación cuando se inicia
    _checkAuthState();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Al volver al primer plano, verificar si el estado de autenticación ha cambiado
      debugPrint('[DEBUG] AuthWrapper: App volvió al primer plano, verificando estado de autenticación');
      _checkAuthState();
    }
  }
  
  // Método para verificar el estado de autenticación actual
  Future<void> _checkAuthState() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Verificar si hay un token almacenado y si es válido
      final hasToken = await authService.hasStoredToken();
      debugPrint('[DEBUG] AuthWrapper: Token disponible: ${hasToken ? "Sí" : "No"}');
      
      if (hasToken) {
        // Si hay token, verificar su validez
        debugPrint('[DEBUG] AuthWrapper: Verificando validez del token');
        final isValid = await authService.verifyToken();
        
        if (isValid) {
          // Si el token es válido, asegurar que estamos marcados como autenticados
          debugPrint('[DEBUG] AuthWrapper: Token válido, actualizando estado de autenticación');
          if (!authService.isAuthenticated.value) {
            authService.isAuthenticated.value = true;
            authService.notifyListeners();
          }
        } else {
          // Si el token no es válido, limpiar estado
          debugPrint('[DEBUG] AuthWrapper: Token no válido, limpiando estado');
          await authService.forceCleanAuthState();
        }
      }
    } catch (e) {
      debugPrint('[DEBUG] AuthWrapper: Error al verificar estado de autenticación: $e');
    } finally {
      // Marcar que la verificación inicial se completó
      if (!_initialCheckDone && mounted) {
        setState(() {
          _initialCheckDone = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado de autenticación
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Si no hemos completado la verificación inicial, mostrar loader
    if (!_initialCheckDone) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return ValueListenableBuilder<bool>(
      valueListenable: authService.isLoading,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: authService.isAuthenticated,
          builder: (context, isAuthenticated, _) {
            // Si está cargando, mostrar un indicador de carga
            if (isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Si está autenticado, mostramos la aplicación principal
            if (isAuthenticated) {
              debugPrint('[DEBUG] AuthWrapper: Usuario autenticado, mostrando AppScaffold');
              return const AppScaffold();
            }
            
            // Si no está autenticado, mostramos la pantalla de login
            debugPrint('[DEBUG] AuthWrapper: Usuario no autenticado, mostrando LoginScreen');
            return const LoginScreen();
          },
        );
      }
    );
  }
}