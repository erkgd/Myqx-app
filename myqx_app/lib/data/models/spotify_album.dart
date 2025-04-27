import 'package:myqx_app/data/models/spotify_track.dart';

class SpotifyAlbum {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String coverUrl;
  final String releaseDate;
  final String spotifyUrl;
  final int totalTracks;
  final List<SpotifyTrack>? tracks;
  final double? rating;
  
  SpotifyAlbum({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    required this.coverUrl,
    required this.releaseDate,
    required this.spotifyUrl,
    required this.totalTracks,
    this.tracks,
    this.rating,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    // Manejar la portada del álbum
    String? coverUrl;
    if (json['images'] != null && json['images'].isNotEmpty) {
      coverUrl = json['images'][0]['url'];
    }

    // Manejar información del artista con seguridad
    String artistName = 'Unknown Artist';
    String artistId = '';
    
    if (json['artists'] != null && 
        json['artists'] is List && 
        json['artists'].isNotEmpty && 
        json['artists'][0] != null) {
      artistName = json['artists'][0]['name'] ?? 'Unknown Artist';
      artistId = json['artists'][0]['id'] ?? '';
    }    // Procesar las pistas si están incluidas en la respuesta
    List<SpotifyTrack>? tracksList;
    if (json['tracks'] != null && json['tracks']['items'] != null) {
      final items = json['tracks']['items'] as List;
      tracksList = items.map((trackJson) => SpotifyTrack.fromJson(trackJson)).toList();
    }

    return SpotifyAlbum(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Album',
      artistName: artistName,
      artistId: artistId,
      coverUrl: coverUrl ?? '',
      releaseDate: json['release_date'] ?? '',
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
      totalTracks: json['total_tracks'] ?? 0,
      tracks: tracksList,
      rating: null,
    );
  }

  // Nuevo método para crear una instancia desde un mapa plano
  factory SpotifyAlbum.fromMap(Map<String, dynamic> map) {
    // Convertir la lista de tracks si existe
    List<SpotifyTrack>? tracksList;
    if (map['tracks'] != null) {
      tracksList = (map['tracks'] as List)
          .map((trackMap) => SpotifyTrack.fromMap(trackMap as Map<String, dynamic>))
          .toList();
    }

    return SpotifyAlbum(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      artistName: map['artist_name'] ?? 'Unknown Artist',
      artistId: map['artist_id'] ?? '',
      coverUrl: map['cover_url'] ?? '',
      releaseDate: map['release_date'] ?? '',
      spotifyUrl: map['spotify_url'] ?? '',
      totalTracks: map['total_tracks'] ?? 0,
      tracks: tracksList,
      rating: map['rating']?.toDouble(),
    );
  }

  // Método para serializar el objeto a JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'artist_id': artistId,
      'cover_url': coverUrl,
      'release_date': releaseDate,
      'spotify_url': spotifyUrl,
      'total_tracks': totalTracks,
      'rating': rating,
      'tracks': tracks?.map((track) => track.toMap()).toList(),
    };
  }
  
  @override
  String toString() {
    return 'SpotifyAlbum(id: $id, name: $name, artistName: $artistName, totalTracks: $totalTracks)';
  }
}