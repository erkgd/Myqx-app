import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myqx_app/presentation/screens/album_screen.dart';
import 'package:myqx_app/presentation/screens/broadcast_screen.dart';
import 'package:myqx_app/presentation/screens/profile_screen.dart';
import 'package:myqx_app/presentation/screens/search_screen.dart';
import 'package:myqx_app/presentation/screens/graph_screen.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:myqx_app/presentation/screens/unaffiliated_profile_screen.dart';
import 'package:myqx_app/core/services/audio_player_service.dart';

class NavbarRoutes {
  // Nombres de rutas para facilitar la navegación
  static const String profile = '/profile';
  static const String broadcast = '/broadcast';
  static const String search = '/search';
  static const String album = '/album';
  static const String unaffiliatedProfile = '/unaffiliated-profile';
  
  // Mapeo de nombres de ruta a índices
  static const Map<String, int> routeIndices = {
    '/': 0,
    '/broadcast': 1,
    '/profile': 2,
    '/search': 3,
    '/album': 4,
    '/unaffiliated-profile': 5
  };
  
  // Método para obtener las páginas con parámetros actualizados
  static List<Widget> getPages(BuildContext context) {
    // Acceder al provider para obtener los parámetros actuales
    final navProvider = Provider.of<NavigationProvider>(context);
    
    return [
      const ProfileScreen(),     // índice 0
      const BroadcastScreen(),   // índice 1
      const GraphScreen(),       // índice 2
      const SearchScreen(),      // índice 3
      
      // AlbumScreen con parámetros dinámicos del provider
      _buildAlbumScreen(navProvider),
      
      // UnaffiliatedProfileScreen con ID del usuario desde el provider
      _buildProfileScreen(navProvider),
    ];
  }
  
  // Método auxiliar para construir AlbumScreen
  static Widget _buildAlbumScreen(NavigationProvider navProvider) {
    if (navProvider.currentAlbumId == null || navProvider.currentAlbumId!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No album selected', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    
    if (navProvider.currentAlbumTitle.isEmpty) {
      // Si solo tenemos ID, usar constructor fromId
      return AlbumScreen.fromId(albumId: navProvider.currentAlbumId!);
    } else {
      // Si tenemos datos completos, usar el constructor normal
      return AlbumScreen(
        albumId: navProvider.currentAlbumId,
        albumTitle: navProvider.currentAlbumTitle,
        artist: navProvider.currentArtist,
        imageUrl: navProvider.currentImageUrl,
        releaseYear: navProvider.currentReleaseYear,
        rating: navProvider.currentRating,
        trackList: navProvider.currentTrackList,
        spotifyUrl: navProvider.currentSpotifyUrl,
      );
    }
  }
  
  // Método auxiliar para construir UnaffiliatedProfileScreen
  static Widget _buildProfileScreen(NavigationProvider navProvider) {
    if (navProvider.currentProfileUserId == null || 
        navProvider.currentProfileUserId!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No user profile selected', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    
    return UnaffiliatedProfileScreen(userId: navProvider.currentProfileUserId!);
  }
}