import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/navbar_routes.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
import 'package:myqx_app/presentation/screens/login_screen.dart';
import 'package:myqx_app/presentation/widgets/general/bottom_navbar.dart';
import 'package:myqx_app/presentation/widgets/general/gradient_background.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget? customBody;
  final bool showNavBar;

  const AppScaffold({
    super.key,
    this.customBody,
    this.showNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    // Intentamos acceder al NavigationProvider con manejo de errores
    NavigationProvider? navProvider;
    try {
      navProvider = Provider.of<NavigationProvider>(context);
    } catch (e) {
      // Si hay un error al obtener el NavigationProvider, regresamos a la pantalla de login
      debugPrint('[DEBUG] Error al acceder a NavigationProvider: $e');
      
      // Después de un breve retraso, navegar a LoginScreen
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
      
      // Mientras tanto, mostrar un indicador de carga
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Verificar que navProvider no sea nulo antes de acceder a sus propiedades
    if (navProvider == null) {
      debugPrint('[DEBUG] NavigationProvider es nulo después de Provider.of');
      return const Scaffold(
        body: Center(
          child: Text('Error al cargar la navegación'),
        ),
      );
    }
    
    final currentIndex = navProvider.currentIndex;
    
    // Obtener las páginas dinámicamente usando el nuevo método getPages
    final pages = NavbarRoutes.getPages(context);
    
    // Utilizamos un índice protegido para evitar errores de rango
    final safeIndex = currentIndex < pages.length 
        ? currentIndex 
        : 0;
    
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: customBody ?? pages[safeIndex],
        bottomNavigationBar: showNavBar 
            ? BottomNavBar(
                currentIndex: navProvider.visibleIndex,
                onTap: (index) => navProvider?.setCurrentIndex(index), // Usar operador ?. para llamada segura
              )
            : null,
      ),
    );
  }
}