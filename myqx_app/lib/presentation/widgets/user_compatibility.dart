import 'package:flutter/material.dart';

class UserCompatibility extends StatelessWidget {
  const UserCompatibility({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Compatibility: 87%',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}