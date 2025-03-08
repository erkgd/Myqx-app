import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/screens/broadcast_screen.dart';
import 'package:myqx_app/presentation/screens/profile_screen.dart';
import 'package:myqx_app/presentation/screens/search_screen.dart';

class NavbarRoutes {
  // Incluir todas las páginas, incluso las que no tienen botón en el navbar
  static final List<Widget> pages = [
    const ProfileScreen(),     // índice 0
    const BroadcastScreen(),   // índice 1
    const ProfileScreen(),     // índice 2
    const SearchScreen(),      // índice 3

  ];
  
  // Para navegar por nombre
  static const Map<String, int> routeIndices = {
    '/': 0,
    '/broadcast': 1,
    '/profile': 2,
    '/search': 3,
  };
}