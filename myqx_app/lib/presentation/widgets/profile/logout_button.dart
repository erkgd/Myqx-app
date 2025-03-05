import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/core/services/spotify_auth_service.dart';
import 'package:myqx_app/presentation/screens/login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: OutlinedButton(
        onPressed: () async {
          // Mostrar indicador de carga inmediatamente
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: CircularProgressIndicator(
                    color: CorporativeColors.mainColor,
                  ),
                ),
              );
            }
          );
          
          // Obtener la instancia del servicio de autenticación
          final authService = SpotifyAuthService();
          
          // Cerrar la sesión
          await authService.logout();
          
          // Cerrar el indicador de carga
          Navigator.of(context).pop();
          
          // Navegar a la pantalla de login y limpiar el historial de navegación
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false,
          );
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