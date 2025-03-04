import 'package:flutter/material.dart';
import 'package:myqx_app/presentation/widgets/general/user_header.dart';
import 'package:myqx_app/presentation/widgets/album_representation/album_header.dart';
import 'package:myqx_app/presentation/widgets/album_representation/album_track_card.dart';

class AlbumScreen extends StatelessWidget {
  final String albumTitle;
  final String artist;
  final String imageUrl;
  final String releaseYear;
  final double rating;
  final List<String> trackList;
  final String spotifyUrl;

  const AlbumScreen({
    Key? key,
    required this.albumTitle,
    required this.artist,
    required this.imageUrl,
    required this.releaseYear,
    required this.rating,
    required this.trackList,
    required this.spotifyUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: UserHeader(
        imageUrl: imageUrl,
        username: artist,
      ),
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget separado para la cabecera del álbum
            AlbumHeader(
              albumTitle: albumTitle,
              artist: artist,
              imageUrl: imageUrl,
              releaseYear: releaseYear,
              rating: rating,
              spotifyUrl: spotifyUrl,
            ),
            
            const SizedBox(height: 20),
            
            
            // Lista de tracks con widget separado para cada canción
            ...trackList.asMap().entries.map((entry) {
              final index = entry.key;
              final track = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: AlbumTrackCard(
                  trackNumber: index + 1,
                  trackName: track,
                  albumCoverUrl: imageUrl,
                  spotifyUrl: '$spotifyUrl?track=${index+1}',
                  songId: 'track_$index',
                  rating: 4.0,
                  onRatingChanged: (newRating) {
                    // Aquí puedes guardar el nuevo rating
                    print('Nueva calificación para $track: $newRating');
                  },
                )
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}