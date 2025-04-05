import 'package:flutter/foundation.dart';
// Importamos las clases que movimos a otros archivos
export 'package:myqx_app/data/models/spotify_track.dart';
export 'package:myqx_app/data/models/spotify_album.dart';

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