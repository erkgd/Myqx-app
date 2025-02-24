class SpotifyUser {
  final String id;
  final String displayName;
  final String email;

  SpotifyUser({
    required this.id,
    required this.displayName,
    required this.email,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      id: json['id'],
      displayName: json['display_name'],
      email: json['email'],
    );
  }
}