import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class AddToPlaylist extends StatelessWidget {
  final String songId;
  final double size;
  
  const AddToPlaylist({
    Key? key,
    required this.songId,
    this.size = 30.0,
  }) : super(key: key);

  void _showAddToPlaylistDialog(BuildContext context) {
    // Aquí podríamos mostrar un diálogo para seleccionar playlist
    // Por ahora solo mostraremos un SnackBar indicando que la funcionalidad está en desarrollo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de añadir a playlist en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: size,
        height: size,
      ),
      icon: Icon(
        Icons.playlist_add,
        size: size,
        color: CorporativeColors.spotifyColor,
      ),
      onPressed: () => _showAddToPlaylistDialog(context),
      splashRadius: size * 0.7,
      tooltip: 'Añadir a una playlist',
    );
  }
}