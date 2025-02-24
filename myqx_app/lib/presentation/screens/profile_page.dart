import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/bottom_navbar.dart';
import 'package:myqx_app/presentation/widgets/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/top_rated_albums.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StarOfTheDay(),
    const UserCompatibility(),
    const TopRatedAlbums(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Lógica para cerrar sesión
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}