import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/constants/navbar_routes.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/widgets/general/app_scaffold.dart';
import 'package:myqx_app/presentation/screens/login_screen.dart';

import 'package:myqx_app/presentation/screens/profile_screen.dart';
import 'package:myqx_app/presentation/screens/profile_screen.dart';
import 'package:myqx_app/presentation/screens/search_screen.dart';
import 'package:myqx_app/presentation/screens/broadcast_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Otros providers que puedas necesitar
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancia del servicio de autenticación de Spotify
    final authService = SpotifyAuthService();
    
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
      // Verificar el estado de autenticación y mostrar la pantalla correspondiente
      home: ValueListenableBuilder<bool>(
        valueListenable: authService.isAuthenticated,
        builder: (context, isAuthenticated, child) {
          // Si el usuario está autenticado, mostrar la aplicación principal
          if (isAuthenticated) {
            return AppScaffold(
              pages: NavbarRoutes.pages,
            );
          } 
          // Si no está autenticado, mostrar la pantalla de login
          else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/broadcast': (context) => const BroadcastScreen(),
      },
    );
  }
}