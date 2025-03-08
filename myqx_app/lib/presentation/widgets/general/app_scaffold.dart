import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/navbar_routes.dart';
import 'package:myqx_app/presentation/providers/navigation_provider.dart';
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
    final navProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navProvider.currentIndex;
    
    // Utilizamos un índice protegido para evitar errores de rango
    final safeIndex = currentIndex < NavbarRoutes.pages.length 
        ? currentIndex 
        : 0;
    
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: customBody ?? NavbarRoutes.pages[safeIndex],
        bottomNavigationBar: showNavBar 
            ? BottomNavBar(
                currentIndex: navProvider.visibleIndex,
                onTap: (index) => navProvider.setCurrentIndex(index),
              )
            : null,
      ),
    );
  }
}