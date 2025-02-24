import 'package:myqx_app/domain/entities/spotify_entities.dart';

abstract class SpotifyRepositoryInterface {
  Future<UserEntity> getUserProfile(String accessToken);
}