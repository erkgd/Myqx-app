// filepath: lib/data/models/spotify_artist.dart

class SpotifyArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final String spotifyUrl;
  final int followers;
  final List<String> genres;
  final int popularity;
  final int userListeningCount; // Escuchas del usuario

  SpotifyArtist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.spotifyUrl,
    required this.followers,
    required this.genres,
    required this.popularity,
    this.userListeningCount = 0, // Valor por defecto 0
  });
  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && json['images'].isNotEmpty) {
      imageUrl = json['images'][0]['url'];
    }

    return SpotifyArtist(
      id: json['id'],
      name: json['name'] ?? 'Unknown Artist',
      imageUrl: imageUrl,
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
      followers: json['followers']?['total'] ?? 0,
      genres: json['genres'] != null 
          ? List<String>.from(json['genres']) 
          : <String>[],
      popularity: json['popularity'] ?? 0,
      userListeningCount: json['userListeningCount'] ?? 0, // Extraer escuchas del usuario
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': imageUrl != null ? [{'url': imageUrl}] : [],
      'external_urls': {'spotify': spotifyUrl},
      'followers': {'total': followers},
      'genres': genres,
      'popularity': popularity,
      'userListeningCount': userListeningCount, // Añadir conteo de escuchas
    };
  }

  @override
  String toString() {
    return 'SpotifyArtist(name: $name, followers: $followers)';
  }
}
