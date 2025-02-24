import 'package:flutter/material.dart';

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
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Star of the Day',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'User Compatibility',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.album),
          label: 'Top Rated Albums',
        ),
      ],
    );
  }
}