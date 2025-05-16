import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/presentation/widgets/general/music_container.dart';
import 'package:myqx_app/data/models/spotify_models.dart';

class TopFiveAlbums extends StatelessWidget {
  final List<SpotifyAlbum> albums;
  final bool loading;
  final String title;

  const TopFiveAlbums({
    Key? key,
    required this.albums,
    this.loading = false,
    this.title = "Top Albums",
  }) : super(key: key);  @override  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contenedor principal
        MusicContainer(
          borderColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título interno
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 12.0, right: 12.0, bottom: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
                child: SizedBox(
                  height: 110, // Altura ajustada para la fila de álbumes
                  child: loading 
                    ? _buildLoadingIndicator()
                    : _buildAlbumsList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(CorporativeColors.mainColor),
      ),
    );
  }
  
  Widget _buildAlbumsList() {
    if (albums.isEmpty) {
      return const Center(
        child: Text(
          'No albums found',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      );
    }
    
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: albums.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final album = albums[index];
        return _buildAlbumCover(album);
      },
    );
  }
    Widget _buildAlbumCover(SpotifyAlbum album) {
    return Tooltip(
      message: '${album.name} - ${album.artistName}',
      child: GestureDetector(
        onTap: () {
          // Aquí podrías añadir la funcionalidad para abrir el álbum en Spotify
        },
        child: Container(
          width: 110, // Ancho fijo para cada portada
          height: 100, // Altura igual al ancho para hacerlo cuadrado
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              album.coverUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CorporativeColors.mainColor,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(
                      Icons.album,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}