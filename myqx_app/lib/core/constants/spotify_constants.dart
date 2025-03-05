class SpotifyConstants {
  static const String clientId = 'da933dccc1434a1a9d952e4a6e2924cc';
  static const String clientSecret = 'c22f589410df471f8021778395f6c8b5';
  static const String redirectUri = 'myqx://callback';
  
  // También deberías sincronizar estos scopes con los que usas en SpotifyAuthService
  static const List<String> scopes = [
    'user-read-private', 
    'user-read-email',
    'user-top-read',
    'user-library-read'
  ];
  
  static const String authUrl = 'https://accounts.spotify.com/authorize';
  static const String tokenUrl = 'https://accounts.spotify.com/api/token';
  static const String apiUrl = 'https://api.spotify.com/v1';
}