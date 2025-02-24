import 'package:flutter/material.dart';
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
    
    return BottomNavigationBar(
      backgroundColor: CorporativeColors.blackColor,
      currentIndex: currentIndex,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            '../assets/images/Home.png',
            width: 50,
            height: 50,
            color: currentIndex == 0 ? CorporativeColors.whiteColor : CorporativeColors.mainColor, 
          ),
          label: '',
    
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            '../assets/images/Broadcast.png',
            width: 50,
            height: 50,
            color: currentIndex == 1 ? CorporativeColors.whiteColor : CorporativeColors.mainColor,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            '../assets/images/GraphIcon.png',
            width: 70,
            height: 70,
            color: currentIndex == 2 ? CorporativeColors.whiteColor : CorporativeColors.mainColor,
          ),
          label: '',
        ),
      ],
    );
  }
}