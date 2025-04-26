import 'package:flutter/foundation.dart';

/// Esta clase maneja la monitorización de scroll para optimizar precarga de datos
class ScrollOptimizer {
  // Singleton pattern
  static final ScrollOptimizer _instance = ScrollOptimizer._internal();
  factory ScrollOptimizer() => _instance;
  ScrollOptimizer._internal();
  
  // Estado de scroll
  bool _isScrolling = false;
  DateTime? _lastScrollTime;
  
  // Umbral de tiempo para considerar que el scroll ha terminado (250ms)
  final Duration _scrollThreshold = const Duration(milliseconds: 250);
  
  /// Notificar que se está produciendo un scroll
  void notifyScrolling() {
    _isScrolling = true;
    _lastScrollTime = DateTime.now();
  }
  
  /// Verificar si el scroll ha terminado basado en un umbral de tiempo
  bool isScrollPaused() {
    if (!_isScrolling) return true;
    if (_lastScrollTime == null) return true;
    
    final timeSinceLastScroll = DateTime.now().difference(_lastScrollTime!);
    if (timeSinceLastScroll > _scrollThreshold) {
      _isScrolling = false;
      return true;
    }
    return false;
  }
  
  /// Ejecuta una acción solo cuando el usuario ha dejado de hacer scroll
  /// para evitar llamadas innecesarias durante scroll rápido
  Future<void> executeWhenScrollPaused(Future<void> Function() action) async {
    if (isScrollPaused()) {
      try {
        await action();
      } catch (e) {
        debugPrint('[ERROR] Error executing scroll-optimized action: $e');
      }
    }
  }
}
