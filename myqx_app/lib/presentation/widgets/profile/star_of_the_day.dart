import 'package:flutter/material.dart';

class StarOfTheDay extends StatelessWidget {
  const StarOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Star of the Day',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}