import 'package:flutter/material.dart';

class SpotifyUserProfile extends StatelessWidget {
  final String displayName;
  final String email;

  const SpotifyUserProfile({
    super.key,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Nombre: $displayName'),
        Text('Email: $email'),
      ],
    );
  }
}