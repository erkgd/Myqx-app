import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

// Este es un ejemplo de cómo implementar el método nodeWidgetWithUserCircle 
// utilizando NavigationProvider para la navegación a perfiles no afiliados.
// Puedes copiar este código y adaptarlo a tu GraphScreen.

Widget nodeWidgetWithUserCircle(BuildContext context, String nodeId, String defaultName, bool isCurrentUser, Map<String, dynamic> userData) {
  // Datos del usuario
  final username = userData['username'] ?? defaultName;
  final imageUrl = userData['profileImage'] ?? '';
  
  // Widget de nodo clickeable
  return GestureDetector(
    onTap: () {
      // Si no es el usuario actual, navegar al perfil no afiliado usando NavigationProvider
      if (!isCurrentUser && nodeId.isNotEmpty) {
        debugPrint('[DEBUG] Navegando al perfil no afiliado con ID: $nodeId');
        // Usar el NavigationProvider para manejar la navegación
        final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
        navigationProvider.navigateToUserProfile(context, nodeId);
      } else if (isCurrentUser) {
        // Si es el usuario actual, mostrar un mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este es tu perfil'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    },
    child: Container(
      width: isCurrentUser ? 70.0 : 55.0, // Tamaños diferentes según si es el usuario actual
      height: isCurrentUser ? 70.0 : 55.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: CorporativeColors.mainColor,
          width: 3.0, // Borde más grueso
        ),
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty 
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  backgroundColor: CorporativeColors.mainColor,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: CorporativeColors.mainColor,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    ),
  );
}
