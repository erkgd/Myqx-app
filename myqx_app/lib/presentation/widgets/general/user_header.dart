import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/general/divisor.dart';
import 'package:myqx_app/presentation/widgets/spotify/user_circle.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class UserHeader extends StatelessWidget implements PreferredSizeWidget {
  final String imageUrl;
  final String username;
  final bool showCircle; // Nuevo parámetro para controlar la visibilidad del círculo

  const UserHeader({
    super.key, 
    required this.imageUrl,
    this.username = 'user', // Valor por defecto
    this.showCircle = false, // Por defecto no se muestra
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8.0),
          child: AppBar(
            toolbarHeight: 70.0,
            backgroundColor: Colors.transparent,
            // Lupa en la izquierda
            leading: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28.0),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ),
            // El botón + se moverá al Stack
            title: const SizedBox(),
            // UserCircle en la derecha
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0, top: 8.0),
                child: UserCircle(
                  username: username,
                  imageUrl: imageUrl,
                  imageSize: 36.0,
                  fontSize: 14.0,
                ),
              ),
            ],
            centerTitle: true,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divisor(),
            ),
          ),
        ),
        
        // Botón "+" en un círculo, posicionado encima del divisor
        // Solo se muestra si showCircle es true
        if (showCircle)
          Positioned(
            left: 0,
            right: 0,
            bottom: -2, // Ajusta para que esté encima del divisor
            child: Center(
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CorporativeColors.gradientColorTop, // Rellenar con el color del gradiente
                  border: Border.all(
                    color: CorporativeColors.mainColor,
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.add,
                    color: CorporativeColors.mainColor,
                    size: 35.0,
                  ),
                  onPressed: () {
                    // Acción del botón más
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}