class SpotifyUser {
  final String displayName;
  final String email;

  SpotifyUser({required this.displayName, required this.email});

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      displayName: json['display_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'email': email,
    };
  }
}