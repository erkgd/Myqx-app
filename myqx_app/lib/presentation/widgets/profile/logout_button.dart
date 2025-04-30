import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/providers/auth_provider.dart';
import 'package:myqx_app/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'dart:io' show exit;

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
          
          try {
            debugPrint('[DEBUG] Iniciando cierre de sesión completo');
            
            // Obtener el AuthService a través de Provider
            final authService = Provider.of<AuthService>(context, listen: false);
            
            // Usar la limpieza forzada completa para asegurar que todos los datos se eliminen
            await authService.forceCleanAuthState();
            
            debugPrint('[DEBUG] Cierre de sesión completado exitosamente');
          } catch (e) {
            debugPrint('[DEBUG] Error durante el cierre de sesión: $e');
          }          finally {
            // Cerrar el indicador de carga
            Navigator.of(context).pop();
            
            // Mostrar mensaje antes de cerrar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cerrando la aplicación...'),
                duration: Duration(milliseconds: 800),
              ),
            );
            
            // Esperar un momento para que el usuario vea el mensaje
            await Future.delayed(const Duration(milliseconds: 1000));
            
            // Cerrar completamente la aplicación
            exit(0);
          }
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