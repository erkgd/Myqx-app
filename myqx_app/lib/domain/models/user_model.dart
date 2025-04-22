import 'dart:convert';

/// Modelo de usuario para la aplicación
class User {
  final String id;
  final String username;
  final String? email;
  final String? name;
  final String? imageUrl;
  final bool hasSpotifyConnected;
  final String? spotifyToken;
  final String? spotifyId;

  User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.imageUrl,
    this.hasSpotifyConnected = false,
    this.spotifyToken,
    this.spotifyId,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? imageUrl,
    bool? hasSpotifyConnected,
    String? spotifyToken,
    String? spotifyId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      hasSpotifyConnected: hasSpotifyConnected ?? this.hasSpotifyConnected,
      spotifyToken: spotifyToken ?? this.spotifyToken,
      spotifyId: spotifyId ?? this.spotifyId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': id,
      'username': username,
      'email': email,
      'name': name,
      'image_url': imageUrl,
      'has_spotify_connected': hasSpotifyConnected,
      'spotify_token': spotifyToken,
      'spotify_id': spotifyId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['userId']?.toString() ?? map['id']?.toString() ?? '',
      username: map['username'] ?? '',
      email: map['email'],
      name: map['name'],
      imageUrl: map['profileImage'] ?? map['image_url'],
      hasSpotifyConnected: map['hasSpotifyConnected'] ?? map['has_spotify_connected'] ?? false,
      spotifyToken: map['spotifyToken'] ?? map['spotify_token'],
      spotifyId: map['spotifyId'] ?? map['spotify_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  /// Constructor especializado para la respuesta del BFF en el login con Spotify
  factory User.fromSpotifyBff(Map<String, dynamic> map) {
    return User(
      id: map['userId']?.toString() ?? '',
      username: map['username'] ?? '',
      spotifyToken: map['spotifyToken'],
      imageUrl: map['profileImage'],
      spotifyId: map['spotifyId'],
      hasSpotifyConnected: map['spotifyToken'] != null,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, hasSpotifyConnected: $hasSpotifyConnected, spotifyId: $spotifyId)';
  }
}