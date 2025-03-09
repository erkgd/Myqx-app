import 'package:flutter/foundation.dart';

class SpotifyUser {
  final String id;
  final String displayName;
  final String? email;
  final String? imageUrl;
  final String spotifyUrl;
  final int followers;

  SpotifyUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.imageUrl,
    required this.spotifyUrl,
    required this.followers,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && json['images'].isNotEmpty) {
      imageUrl = json['images'][0]['url'];
    }

    return SpotifyUser(
      id: json['id'],
      displayName: json['display_name'] ?? 'Spotify User',
      email: json['email'],
      imageUrl: imageUrl,
      spotifyUrl: json['external_urls']['spotify'] ?? '',
      followers: json['followers']['total'] ?? 0,
    );
  }

  // Método para serializar el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'images': imageUrl != null ? [{'url': imageUrl}] : [],
      'external_urls': {'spotify': spotifyUrl},
      'followers': {'total': followers},
    };
  }
}

class SpotifyTrack {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String? imageUrl;
  final String spotifyUrl;
  final String? albumId; // Añadir esta propiedad

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.imageUrl,
    required this.spotifyUrl,
    this.albumId, // Añadir este parámetro
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
    }

    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artistName: artistName,
      albumName: albumName,
      imageUrl: imageUrl,
      spotifyUrl: json['external_urls']?['spotify'] ?? '',
      albumId: albumId, // Asignar el ID del álbum
    );
  }
  
  // Constructor para albumJson también necesita actualizarse
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
}

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
      tracks: null,
      rating: null,
    );
  }

  // Método para serializar el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': [{'name': artistName}],
      'images': [{'url': coverUrl}],
      'external_urls': {'spotify': spotifyUrl},
    };
  }
}