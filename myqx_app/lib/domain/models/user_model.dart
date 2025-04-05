import 'dart:convert';

/// Modelo de usuario para la aplicación
class User {
  final String id;
  final String username;
  final String? email;
  final String? name;
  final String? imageUrl;
  final bool hasSpotifyConnected;

  User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.imageUrl,
    this.hasSpotifyConnected = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? imageUrl,
    bool? hasSpotifyConnected,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      hasSpotifyConnected: hasSpotifyConnected ?? this.hasSpotifyConnected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'image_url': imageUrl,
      'has_spotify_connected': hasSpotifyConnected,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'],
      name: map['name'],
      imageUrl: map['image_url'],
      hasSpotifyConnected: map['has_spotify_connected'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, hasSpotifyConnected: $hasSpotifyConnected)';
  }
}