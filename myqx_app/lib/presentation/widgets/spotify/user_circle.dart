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

  @override
  Widget build(BuildContext context) {
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
        ),
      ],
    );
  }
}