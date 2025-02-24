import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/app_scaffold.dart';
import 'package:myqx_app/presentation/widgets/star_of_the_day.dart';
import 'package:myqx_app/presentation/widgets/user_compatibility.dart';
import 'package:myqx_app/presentation/widgets/top_rated_albums.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Widget> _pages = [
    const StarOfTheDay(),
    const UserCompatibility(),
    const TopRatedAlbums(),
  ];

  int _currentContentIndex = 1;

  void _updateContent(int index) {
    setState(() {
      _currentContentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: _pages[_currentContentIndex],
      onIndexChanged: _updateContent,
    );
  }
}