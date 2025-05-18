import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  // Propiedades existentes
  int _currentIndex = 0;
  
  // Getter para el índice actual
  int get currentIndex => _currentIndex;
  
  // Getter para el índice visible (puede ser diferente si necesitas ocultar alguna página)
  int get visibleIndex => _currentIndex > 2 ? 0 : _currentIndex;
  
  // Método para cambiar el índice actual
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
  
  // NUEVAS PROPIEDADES PARA ÁLBUM
  // ==============================
  
  // Propiedades del álbum actual
  String? currentAlbumId;
  String currentAlbumTitle = '';
  String currentArtist = '';
  String currentImageUrl = '';
  String currentReleaseYear = '';
  double currentRating = 0.0;
  List<String> currentTrackList = [];
  String currentSpotifyUrl = '';
  
  // Método para navegar a un álbum con todos los datos
  void navigateToAlbum(
    BuildContext context, {
    String? albumId,
    required String albumTitle,
    required String artist,
    required String imageUrl,
    required String releaseYear,
    required double rating,
    required List<String> trackList,
    required String spotifyUrl,
  }) {
    // Actualizar todas las propiedades
    currentAlbumId = albumId;
    currentAlbumTitle = albumTitle;
    currentArtist = artist;
    currentImageUrl = imageUrl;
    currentReleaseYear = releaseYear;
    currentRating = rating;
    currentTrackList = List<String>.from(trackList); // Crear copia para seguridad
    currentSpotifyUrl = spotifyUrl;
    
    // Navegar a la página de álbum (índice 4)
    setCurrentIndex(4);
  }
  
  // Método para navegar solo con ID (carga diferida)
  void navigateToAlbumById(BuildContext context, String albumId) {
    // Validar el ID
    if (albumId.isEmpty) {
      debugPrint('Error: navigateToAlbumById recibió un ID vacío');
      return;
    }

    // Limpiar datos antiguos excepto el ID
    currentAlbumId = albumId;
    currentAlbumTitle = '';
    currentArtist = '';
    currentImageUrl = '';
    currentReleaseYear = '';
    currentRating = 0.0;
    currentTrackList = [];
    currentSpotifyUrl = '';
    
    // Registrar la acción para debugging
    debugPrint('Navegando al álbum con ID: $albumId');
    
    // Navegar a la página de álbum
    setCurrentIndex(4);
  }
  
  // PROPIEDADES Y MÉTODOS PARA PERFIL NO AFILIADO
  // =============================================
    // ID del usuario cuyo perfil se está visualizando
  String? currentProfileUserId;
  // Información adicional del perfil
  String? profileImageUrl;
  bool isFollowing = false;
  
  // Método para navegar al perfil de un usuario no afiliado
  void navigateToUserProfile(BuildContext context, String userId, {String? imageUrl, bool isFollowing = false}) {
    // Validar el ID
    if (userId.isEmpty) {
      debugPrint('Error: navigateToUserProfile recibió un ID vacío');
      return;
    }
    
    // Almacenar el ID y datos adicionales del usuario
    currentProfileUserId = userId;
    profileImageUrl = imageUrl;
    this.isFollowing = isFollowing;
    
    // Registrar la acción para debugging
    debugPrint('Navegando al perfil de usuario con ID: $userId (isFollowing: $isFollowing)');
    
    // Navegar al perfil usando el índice correcto (5 para unaffiliated-profile)
    setCurrentIndex(5);
  }
  
  // Limpiar datos del perfil actual
  void clearCurrentProfile() {
    currentProfileUserId = null;
  }
}