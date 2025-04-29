import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class UserCircle extends StatelessWidget {
  final String username;
  final String imageUrl;
  final double imageSize;
  final double fontSize;
  
  const UserCircle({
    super.key,
    required this.username,
    required this.imageUrl,
    this.imageSize = 30.0,
    this.fontSize = 14.0,
  });
  
  /// Construye un avatar de placeholder cuando la imagen no está disponible o falla
  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      backgroundColor: CorporativeColors.mainColor,
      radius: imageSize / 2,
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Depuración para ver la URL de la imagen
    debugPrint('[USER_CIRCLE] Construyendo UserCircle para $username con URL: "$imageUrl"');
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre de usuario
        Text(
          username,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8.0),
        // Imagen de perfil circular - Garantizada forma circular
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CorporativeColors.mainColor,
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty 
                ? FadeInImage.assetNetwork(
                    placeholder: 'assets/images/Logo_squared.png',
                    image: imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    imageErrorBuilder: (context, error, stackTrace) {
                      debugPrint('[USER_CIRCLE] ⚠️ Error al cargar la imagen: $error para URL: $imageUrl');
                      debugPrint('[USER_CIRCLE] 🔍 URL exacta que falló: "$imageUrl"');
                      return _buildPlaceholderAvatar();
                    },
                  )
                : _buildPlaceholderAvatar(),
            ),
          ),
        ),
      ],
    );
  }
}