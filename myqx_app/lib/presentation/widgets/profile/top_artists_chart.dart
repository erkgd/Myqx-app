import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';
import 'package:myqx_app/data/models/spotify_artist.dart';
import 'package:myqx_app/presentation/widgets/spotify/open_spotify_button.dart';

class TopArtistsChart extends StatelessWidget {
  final List<SpotifyArtist> artists;
  
  const TopArtistsChart({
    super.key,
    required this.artists,
  });

  @override
  Widget build(BuildContext context) {
    // Asegurar que tenemos artistas para mostrar
    if (artists.isEmpty) {
      return const Center(
        child: Text(
          'No artist data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Tomar solo los 3 primeros artistas
    final topThree = artists.length > 3 ? artists.sublist(0, 3) : artists;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CorporativeColors.blackColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: CorporativeColors.mainColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Artists',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CorporativeColors.whiteColor,
            ),
          ),
          const SizedBox(height: 10),          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {                // Encontrar el artista con más escuchas del usuario para escalar el gráfico
                final maxListeningCount = topThree.map((a) => a.userListeningCount).reduce(
                  (max, value) => value > max ? value : max);
                
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topThree.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final artist = topThree[index];                    // Establecemos anchos fijos basados en la posición para asegurar diferencias visuales
                    double barWidth;
                    
                    if (index == 0) {
                      // El artista top ocupa el 80% del ancho disponible
                      barWidth = constraints.maxWidth * 0.8;
                    } else if (index == 1) {
                      // El segundo artista ocupa el 50% del ancho
                      barWidth = constraints.maxWidth * 0.5;
                    } else {
                      // El tercer artista ocupa el 30% del ancho
                      barWidth = constraints.maxWidth * 0.3;
                    }
                    
                    // Para depuración - imprimir los valores
                    debugPrint("Artist: ${artist.name}, Index: $index, Width: $barWidth");
                    
                    return Container(
                      height: 50,  // Altura fija para cada elemento del artista
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Imagen del artista
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: artist.imageUrl != null ? DecorationImage(
                                    image: NetworkImage(artist.imageUrl!),
                                    fit: BoxFit.cover,
                                  ) : null,
                                ),
                                child: artist.imageUrl == null ? const Icon(
                                  Icons.person,
                                  size: 15,
                                  color: Colors.white70,
                                ) : null,
                              ),
                              const SizedBox(width: 8),
                              // Nombre del artista
                              Expanded(
                                child: Text(
                                  artist.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: CorporativeColors.whiteColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Barra
                          Stack(
                            children: [
                              // Fondo de la barra
                              Container(
                                width: constraints.maxWidth,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Barra de progreso
                              Container(
                                width: barWidth,
                                height: 15,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      CorporativeColors.gradientColorBottom,
                                      CorporativeColors.mainColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
