import 'package:flutter/material.dart';

class MusicMetadata extends StatelessWidget {
  final String artist;
  final String musicname;

  const MusicMetadata({
    Key? key,
    required this.artist,
    required this.musicname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //-------------------------Artista
        Text(
          artist,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2), // Pequeño espacio entre artista y nombre de canción
        //-------------------------MUSICA
        Text(
          musicname,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12.0,
          ),
          overflow: TextOverflow.ellipsis, // Trunca el texto si es demasiado largo
        ),
      ],
    );
  }
}