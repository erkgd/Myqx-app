import 'package:flutter/material.dart';

class TopRatedAlbums extends StatelessWidget {
  const TopRatedAlbums({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Top Rated Albums',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}