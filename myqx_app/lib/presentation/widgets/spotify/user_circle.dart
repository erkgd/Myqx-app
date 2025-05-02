import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/performance_service.dart';
import 'package:myqx_app/presentation/widgets/general/lazy_image.dart';

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
            ),            child: ClipOval(
              child: imageUrl.isNotEmpty 
                ? LazyImage(
                    imageUrl: imageUrl,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.grey[300],
                      child: Image.asset(
                        'assets/images/Logo_squared.png',
                        width: imageSize * 0.7,
                        height: imageSize * 0.7,
                      ),
                    ),
                    errorWidget: _buildPlaceholderAvatar(),
                  )
                : _buildPlaceholderAvatar(),
            ),
          ),
        ),
      ],
    );
  }
}