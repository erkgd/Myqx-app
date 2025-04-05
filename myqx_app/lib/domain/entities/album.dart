import 'track.dart';

class Album {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String? coverUrl;
  final String releaseDate;
  final String sourceUrl; // URL de la plataforma de origen (Spotify, etc.)
  final int totalTracks;
  final List<Track>? tracks;
  final double? rating;
  final String source; // Identificador de la fuente (ej: "spotify")

  Album({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    this.coverUrl,
    required this.releaseDate,
    required this.sourceUrl,
    required this.totalTracks,
    this.tracks,
    this.rating,
    required this.source,
  });

  @override
  String toString() {
    return 'Album(id: $id, name: $name, artistName: $artistName, totalTracks: $totalTracks, source: $source)';
  }
}