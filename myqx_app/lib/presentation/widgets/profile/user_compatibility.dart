import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';

class UserCompatibility extends StatefulWidget {
  final int compatibilityPercentage;
  final bool loading; // Nuevo parámetro para indicar si está en modo carga
  
  const UserCompatibility({
    super.key, 
    required this.compatibilityPercentage,
    this.loading = false, // Por defecto, no está en modo carga
  });

  @override
  State<UserCompatibility> createState() => _UserCompatibilityState();
}

class _UserCompatibilityState extends State<UserCompatibility> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _timer; // Cambiado a nullable - importante
  int _displayPercentage = 0;
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    _displayPercentage = widget.compatibilityPercentage;
    
    // Inicializa el controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Duración de cada animación
    );
    
    if (widget.loading) {
      _startLoadingAnimation();
    }
  }
  
  void _startLoadingAnimation() {
    // Actualiza el valor cada 800ms
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          // Genera un número aleatorio entre 0 y 100
          _displayPercentage = _random.nextInt(101);
        });
        
        // Inicia la animación de fade
        _animationController.reset();
        _animationController.forward();
      }
    });
  }
  
  @override
  void didUpdateWidget(UserCompatibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si cambia el estado de carga, actualiza la animación
    if (widget.loading != oldWidget.loading) {
      if (widget.loading) {
        _startLoadingAnimation();
      } else {
        _timer?.cancel(); // Ahora usamos ?. porque _timer puede ser null
        setState(() {
          _displayPercentage = widget.compatibilityPercentage;
        });
      }
    }
    
    // Si cambió el porcentaje y no estamos en modo carga
    if (!widget.loading && widget.compatibilityPercentage != oldWidget.compatibilityPercentage) {
      setState(() {
        _displayPercentage = widget.compatibilityPercentage;
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    // Verificamos si _timer es null antes de intentar cancelarlo
    _timer?.cancel();
    super.dispose();
  }

  String _getCompatibilityLevel() {
    if (_displayPercentage >= 70) {
      return 'High';
    } else if (_displayPercentage >= 40) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  Color _getLevelColor() {
    if (_displayPercentage >= 70) {
      return Colors.green;
    } else if (_displayPercentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MusicContainer(
      borderColor: CorporativeColors.mainColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Esto evita que crezca demasiado
          children: [
            const Text(
              'Compatibility',
              style: TextStyle(
                fontSize: 14,
                color: CorporativeColors.mainColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Número de compatibilidad grande con efecto de fade
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Efecto de fade para suavizar las transiciones
                return Opacity(
                  opacity: widget.loading
                      ? 0.5 + (_animationController.value * 0.5) // Oscila entre 0.5 y 1.0 de opacidad
                      : 1.0, // Sin animación en modo normal
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_displayPercentage',
                    style: const TextStyle(
                      fontSize: 60, // Tamaño ajustado
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    '%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CorporativeColors.mainColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Nivel de compatibilidad
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getLevelColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getLevelColor(),
                  width: 1,
                ),
              ),
              child: Text(
                _getCompatibilityLevel(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getLevelColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}