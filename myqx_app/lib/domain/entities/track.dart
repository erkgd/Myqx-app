class Track {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String? imageUrl;
  final String sourceUrl; // URL de la plataforma de origen (Spotify, etc.)
  final String? albumId;
  final String source; // Identificador de la fuente (ej: "spotify")

  Track({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    this.imageUrl,
    required this.sourceUrl,
    this.albumId,
    required this.source,
  });

  @override
  String toString() {
    return 'Track(id: $id, name: $name, artistName: $artistName, albumName: $albumName, source: $source)';
  }
}