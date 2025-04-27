class SpotifyTrack {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String? imageUrl;
  final String spotifyUrl;
  final String? albumId; // ID del álbum
  final String? previewUrl; // URL para reproducir vista previa

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.imageUrl,
    required this.spotifyUrl,
    this.albumId, // Parámetro para el ID del álbum
    this.previewUrl, // URL para reproducción
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    String albumName = 'Unknown Album';
    String? albumId; // Variable para el ID del álbum
    
    // Verificar si tenemos información del álbum
    if (json['album'] != null) {
      if (json['album']['images'] != null && json['album']['images'].isNotEmpty) {
        imageUrl = json['album']['images'][0]['url'];
      }
      albumName = json['album']['name'] ?? 'Unknown Album';
      albumId = json['album']['id']; // Extraer el ID del álbum
    }

    // Manejo seguro de artistas
    String artistName = 'Unknown Artist';
    if (json['artists'] != null && 
        json['artists'] is List && 
        json['artists'].isNotEmpty) {
      artistName = json['artists'][0]['name'] ?? 'Unknown Artist';
    }    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artistName: artistName,
      albumName: albumName,
      imageUrl: imageUrl,
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
      albumId: albumId, // Asignar el ID del álbum
      previewUrl: json['preview_url'], // URL para reproducir una vista previa (30 segundos)
    );
  }
  
  // Constructor para datos provenientes de un álbum
  factory SpotifyTrack.fromAlbumJson(Map<String, dynamic> json, String albumName, String? albumImageUrl, String albumId) {
    // Manejo seguro de artistas
    String artistName = 'Unknown Artist';
    if (json['artists'] != null && 
        json['artists'] is List && 
        json['artists'].isNotEmpty) {
      artistName = json['artists'][0]['name'] ?? 'Unknown Artist';
    }

    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artistName: artistName,
      albumName: albumName,
      imageUrl: albumImageUrl,
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
      albumId: albumId, // Añadir el ID del álbum
    );
  }

  // Nuevo método para crear una instancia desde un mapa plano
  factory SpotifyTrack.fromMap(Map<String, dynamic> map) {
    return SpotifyTrack(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      artistName: map['artist_name'] ?? 'Unknown Artist',
      albumName: map['album_name'] ?? 'Unknown Album',
      imageUrl: map['image_url'],
      spotifyUrl: map['spotify_url'] ?? '',
      albumId: map['album_id'],
    );
  }

  // Método para serializar el objeto a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'album_name': albumName,
      'image_url': imageUrl,
      'spotify_url': spotifyUrl,
      'album_id': albumId,
    };
  }

  @override
  String toString() {
    return 'SpotifyTrack(id: $id, name: $name, artistName: $artistName, albumName: $albumName)';
  }
}