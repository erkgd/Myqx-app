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
  
  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.imageUrl,
    required this.spotifyUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['album'] != null && 
        json['album']['images'] != null && 
        json['album']['images'].isNotEmpty) {
      imageUrl = json['album']['images'][0]['url'];
    }

    return SpotifyTrack(
      id: json['id'],
      name: json['name'],
      artistName: json['artists'][0]['name'],
      albumName: json['album']['name'],
      imageUrl: imageUrl,
      spotifyUrl: json['external_urls']['spotify'],
    );
  }

  // Método para serializar el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': [{'name': artistName}],
      'album': {
        'name': albumName,
        'images': imageUrl != null ? [{'url': imageUrl}] : [],
      },
      'external_urls': {'spotify': spotifyUrl},
    };
  }
}

class SpotifyAlbum {
  final String id;
  final String name;
  final String artistName;
  final String coverUrl;
  final String spotifyUrl;
  
  SpotifyAlbum({
    required this.id,
    required this.name,
    required this.artistName,
    required this.coverUrl,
    required this.spotifyUrl,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['images'] != null && json['images'].isNotEmpty) {
      coverUrl = json['images'][0]['url'];
    }

    return SpotifyAlbum(
      id: json['id'],
      name: json['name'],
      artistName: json['artists'][0]['name'],
      coverUrl: coverUrl ?? '',
      spotifyUrl: json['external_urls']['spotify'],
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