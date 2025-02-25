import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget implements PreferredSizeWidget {
  final String imageUrl;

  const UserHeader({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // Acción de cierre de sesión
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}