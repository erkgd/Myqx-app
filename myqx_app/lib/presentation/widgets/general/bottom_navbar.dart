import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double iconSize = constraints.maxWidth * 0.08; // Ajusta el tamaño del icono según el ancho disponible
          
          return BottomNavigationBar(
            backgroundColor: Colors.black,
            elevation: 0,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Container(
                      decoration: currentIndex == 0
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: CorporativeColors.gradientColorBottom,
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                ),
                              ],
                            )
                          : null,
                      child: SvgPicture.asset(
                        'assets/images/HomeIcon.svg',
                        fit: BoxFit.contain,
                        color: CorporativeColors.whiteColor,
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Container(
                      decoration: currentIndex == 1
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: CorporativeColors.gradientColorBottom,
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                ),
                              ],
                            )
                          : null,
                      child: SvgPicture.asset(
                        'assets/images/BroadcastIcon.svg',
                        fit: BoxFit.contain,
                        color: CorporativeColors.whiteColor,
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Container(
                      decoration: currentIndex == 2
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: CorporativeColors.gradientColorBottom,
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                ),
                              ],
                            )
                          : null,
                      child: Transform.scale(
                        scale: 1.5, // Escala el icono
                        child: SvgPicture.asset(
                          'assets/images/GraphIcon.svg',
                          fit: BoxFit.contain,
                          color: CorporativeColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
            ],
          );
        },
      ),
    );
  }
}