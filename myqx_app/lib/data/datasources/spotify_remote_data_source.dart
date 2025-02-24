import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myqx_app/core/constants/spotify_constants.dart';

class SpotifyRemoteDataSource {
  Future<String> authenticate() async {
    final url = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': SpotifyConstants.clientId,
      'scope': SpotifyConstants.scopes.join(' '),
      'redirect_uri': SpotifyConstants.redirectUri,
    });

    final result = await FlutterWebAuth.authenticate(
      url: url.toString(),
      callbackUrlScheme: 'http',
    );

    final code = Uri.parse(result).queryParameters['code'];
    return code!;
  }

  Future<Map<String, dynamic>> getAccessToken(String code) async {
    final response = await http.post(
      Uri.https('accounts.spotify.com', '/api/token'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode(
                '${SpotifyConstants.clientId}:${SpotifyConstants.clientSecret}')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': SpotifyConstants.redirectUri,
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final response = await http.get(
      Uri.https('api.spotify.com', '/v1/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    return jsonDecode(response.body);
  }
}