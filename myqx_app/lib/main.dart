import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
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
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado de autenticación
    final authService = Provider.of<AuthService>(context);
    
    // Escuchamos los cambios en el estado de autenticación
    return ValueListenableBuilder<bool>(
      valueListenable: authService.isAuthenticated,
      builder: (context, isAuthenticated, _) {
        // Si está autenticado, mostramos la aplicación principal
        if (isAuthenticated) {
          return AppScaffold();
        }
        // Si no está autenticado, mostramos la pantalla de login
        return const LoginScreen();
      },
    );
  }
}