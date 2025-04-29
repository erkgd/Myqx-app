import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importación para rootBundle
import 'package:flutter_svg/flutter_svg.dart';

/// Servicio para cargar SVGs de forma segura con fallback a iconos normales
class SvgSafeService {
  // Cache para SVGs ya validados y procesados
  static final Map<String, bool> _validSvgCache = {};
  
  // Método mejorado para cargar SVGs de forma segura
  static Widget loadSvg({
    required String svgPath,
    required double width,
    required double height,
    Color? color,
    IconData fallbackIcon = Icons.error,
    Color? fallbackColor,
  }) {
    // Si ya sabemos que el SVG es inválido, usamos directamente el icono fallback
    if (_validSvgCache.containsKey(svgPath) && _validSvgCache[svgPath] == false) {
      return Icon(
        fallbackIcon,
        size: width < height ? width : height,
        color: fallbackColor ?? color,
      );
    }
    
    // Intentamos cargar el SVG con múltiples niveles de protección
    return FutureBuilder<Widget>(
      // Usamos Future.microtask para mover el procesamiento fuera del ciclo de microtareas principal
      future: Future.microtask(() {
        try {
          // Validar si podemos cargar el SVG, almacenando el resultado en la caché
          _validSvgCache[svgPath] = true;
          
          // Retornamos el widget SvgPicture normalmente
          return SvgPicture.asset(
            svgPath,
            width: width,
            height: height,
            colorFilter: color != null 
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
          );
        } catch (e) {
          debugPrint('[SVG_SAFE] ⚠️ Error al validar SVG $svgPath: $e');
          _validSvgCache[svgPath] = false;
          // Retornamos el fallback en caso de error
          return Icon(
            fallbackIcon,
            size: width < height ? width : height,
            color: fallbackColor ?? color,
          );
        }
      }).catchError((error) {
        // Nivel extra de protección para cualquier error en la microtarea
        debugPrint('[SVG_SAFE] 🚨 Error crítico con SVG $svgPath: $error');
        _validSvgCache[svgPath] = false;
        return Icon(
          fallbackIcon,
          size: width < height ? width : height,
          color: fallbackColor ?? color,
        );
      }),
      initialData: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Icon(
            fallbackIcon,
            size: width * 0.8,
            color: (fallbackColor ?? color)?.withOpacity(0.5),
          ),
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return snapshot.data!;
        }
        // Mostramos el icono fallback mientras carga o si hay error
        return Icon(
          fallbackIcon,
          size: width < height ? width : height,
          color: fallbackColor ?? color,
        );
      },
    );
  }
  
  /// Valida previamente un conjunto de SVGs para evitar errores posteriores
  static Future<void> preloadSvgs(List<String> svgPaths) async {
    for (final path in svgPaths) {
      try {
        // Intentamos cargar el SVG para validar
        await rootBundle.load(path);
        _validSvgCache[path] = true;
        debugPrint('[SVG_SAFE] ✅ SVG precargado exitosamente: $path');
      } catch (e) {
        _validSvgCache[path] = false;
        debugPrint('[SVG_SAFE] ❌ SVG inválido detectado en precarga: $path');
      }
    }
  }
  
  /// Limpia la caché de SVGs validados
  static void clearCache() {
    _validSvgCache.clear();
  }
}
