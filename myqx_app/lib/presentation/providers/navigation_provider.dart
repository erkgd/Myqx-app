import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  int get visibleIndex => _currentIndex > 2 ? 0 : _currentIndex; // Para navbar

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
  
  // Método encapsulado para navegación por índice
  void navigateToIndex(BuildContext context, int index) {
    final oldIndex = _currentIndex;
    setCurrentIndex(index);
    
    // Navegar a la ruta principal si estamos en otra página
    if (ModalRoute.of(context)?.settings.name != '/') {
      Navigator.pushReplacementNamed(context, '/');
    } 
    // Si estamos en la ruta principal pero el índice no cambió (o es el mismo tipo de página)
    // forzar una actualización para asegurar que la UI refleje el cambio
    else if (oldIndex == index) {
      notifyListeners();
    }
  }
  
  // Métodos de conveniencia para navegaciones comunes
  void navigateToHome(BuildContext context) => navigateToIndex(context, 0);
  void navigateToBroadcast(BuildContext context) => navigateToIndex(context, 1);
  void navigateToProfile(BuildContext context) => navigateToIndex(context, 2);
  void navigateToSearch(BuildContext context) => navigateToIndex(context, 3);
  void navigateToAlbum(BuildContext context) => navigateToIndex(context, 4);
}