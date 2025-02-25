import 'package:myqx_app/data/datasources/spotify_remote_data_source.dart';
import 'package:myqx_app/data/models/spotify_user.dart';

class SpotifyRepository {
  final SpotifyRemoteDataSource remoteDataSource;

  SpotifyRepository({required this.remoteDataSource});

  Future<SpotifyUser> getUserProfile(String accessToken) async {
    final userProfile = await remoteDataSource.getUserProfile(accessToken);
    return SpotifyUser.fromJson(userProfile);
  }
}