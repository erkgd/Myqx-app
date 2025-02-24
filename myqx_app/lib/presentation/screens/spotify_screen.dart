import 'package:flutter/material.dart';
import 'package:myqx_app/data/repositories/spotify_repository.dart';
import 'package:myqx_app/data/datasources/spotify_remote_data_source.dart';

class SpotifyScreen extends StatefulWidget {
  const SpotifyScreen({super.key});

  @override
  State<SpotifyScreen> createState() => _SpotifyScreenState();
}

class _SpotifyScreenState extends State<SpotifyScreen> {
  final SpotifyRepository _repository = SpotifyRepository(
    remoteDataSource: SpotifyRemoteDataSource(),
  );
  Map<String, dynamic>? _userProfile;

  Future<void> _loginWithSpotify() async {
    try {
      final code = await _repository.remoteDataSource.authenticate();
      final tokenResponse = await _repository.remoteDataSource.getAccessToken(code);
      final accessToken = tokenResponse['access_token'];

      final userProfile = await _repository.getUserProfile(accessToken);
      setState(() {
        _userProfile = userProfile.toJson();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify API en Flutter'),
      ),
      body: Center(
        child: _userProfile == null
            ? ElevatedButton(
                onPressed: _loginWithSpotify,
                child: const Text('Iniciar sesión con Spotify'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nombre: ${_userProfile!['display_name']}'),
                  Text('Email: ${_userProfile!['email']}'),
                ],
              ),
      ),
    );
  }
}