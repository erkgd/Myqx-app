import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: OutlinedButton(
        onPressed: () {
          // Ejecuta la lógica de logout directamente
          debugPrint('User logged out');
          
          // Aquí implementarías la lógica real de logout
          // Por ejemplo:
          // context.read<AuthBloc>().add(AuthLogoutRequested());
          // Navigator.of(context).pushReplacementNamed('/login');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: CorporativeColors.whiteColor, 
            width: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          foregroundColor: CorporativeColors.whiteColor,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}