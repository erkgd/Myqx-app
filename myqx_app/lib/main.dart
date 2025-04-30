import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/utils/cache_manager.dart';
import 'package:myqx_app/core/services/audio_player_service.dart';
import 'package:myqx_app/core/services/rating_service.dart';
import 'package:myqx_app/core/services/broadcast_service.dart';
import 'package:myqx_app/core/services/svg_safe_service.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:myqx_app/presentation/providers/auth_provider.dart';
import 'package:myqx_app/presentation/providers/spotify_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';
import 'package:myqx_app/presentation/screens/login_screen.dart';
import 'package:myqx_app/presentation/screens/unaffiliated_profile_screen.dart';
import 'package:flutter/foundation.dart';

/// Función para precargar SVGs al iniciar la app
Future<void> _preloadSvgAssets() async {
  // Lista de SVGs usados en la aplicación
  final svgAssets = [
    'assets/images/spotifyLogo.svg',
    'assets/images/spotify-like-icon.svg',
    'assets/images/spotify-icon-liked.svg',
    'assets/images/HomeIcon.svg',
    'assets/images/BroadcastIcon.svg',
    'assets/images/GraphIcon.svg',
  ];
  
  // Precargar de forma segura
  try {
    debugPrint('[APP_INIT] 🔄 Precargando SVGs...');
    await SvgSafeService.preloadSvgs(svgAssets);
    debugPrint('[APP_INIT] ✅ SVGs precargados correctamente');
  } catch (e) {
    debugPrint('[APP_INIT] ❌ Error al precargar SVGs: $e');
    // Continuar con la ejecución incluso si hay errores
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check app version and clear caches if needed
  await CacheManager().checkAndClearCachesOnVersionChange();
  
  // Precargar todos los SVGs para validarlos y evitar errores durante la ejecución
  await _preloadSvgAssets();
  
  // Configurar el manejo global de errores para evitar que los errores de SVG causen fallos en la app
  FlutterError.onError = (FlutterErrorDetails details) {
    // Filtrar errores relacionados con SVG y permitir que otros errores se muestren normalmente
    if (details.exception.toString().contains('SVG') || 
        details.exception.toString().contains('svg')) {
      debugPrint('[ERROR_HANDLER] ⚠️ Se detectó un error en SVG: ${details.exception}');
      // No propagar el error para que la aplicación no se interrumpa
    } else {
      FlutterError.presentError(details);
    }
  };
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SpotifyAuthProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
        ChangeNotifierProvider(create: (_) => RatingService()),
        ChangeNotifierProvider(create: (_) => BroadcastService()),
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
      // Definición de rutas nombradas
      routes: {
        '/unaffiliated-profile': (context) => UnaffiliatedProfileScreen(
          userId: ModalRoute.of(context)!.settings.arguments as String,
        ),
      },
      home: const AuthWrapper(),
    );
  }
}

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
      // Al volver al primer plano, solo verificamos que el token aún sea válido
      // sin limpiar la sesión si la app estuvo en segundo plano
      debugPrint('[DEBUG] AuthWrapper: App volvió al primer plano, verificando si el token sigue válido');
      _checkTokenStillValid();
    }
  }
  
  // Método para verificar que el token sigue siendo válido sin limpiar la sesión
  Future<void> _checkTokenStillValid() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      // Verificar si hay un token almacenado y si es válido
      final hasToken = await authService.hasStoredToken();
      
      if (hasToken) {
        final isValid = await authService.verifyToken();
          // Si el token es válido, nos aseguramos que isAuthenticated sea true
        if (isValid && !authService.isAuthenticated.value) {
          authService.isAuthenticated.value = true;
          // No necesitamos llamar a notifyListeners() porque ValueNotifier ya notifica
        }
      }
    } catch (e) {
      debugPrint('[DEBUG] AuthWrapper: Error al verificar token: $e');
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
          
          // Also clear caches when auth state is invalid
          await CacheManager().clearAllCaches();
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
    final authService = Provider.of<AuthService>(context);

    // Si no hemos completado la verificación inicial, mostrar loader y forzar el chequeo
    if (!_initialCheckDone) {
      // Llama a _checkAuthState si aún no se ha hecho
      Future.microtask(() => _checkAuthState());
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
            if (isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (isAuthenticated) {
              debugPrint('[DEBUG] AuthWrapper: Usuario autenticado, mostrando AppScaffold');
              return const AppScaffold();
            }
            debugPrint('[DEBUG] AuthWrapper: Usuario no autenticado, mostrando LoginScreen');
            return const LoginScreen();
          },
        );
      }
    );
  }
}