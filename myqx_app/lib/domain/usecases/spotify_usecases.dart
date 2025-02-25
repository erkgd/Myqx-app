import 'package:myqx_app/domain/repositories/spotify_repository_interface.dart';
import 'package:myqx_app/domain/entities/spotify_entities.dart';

class GetUserProfile {
  final SpotifyRepositoryInterface repository;

  GetUserProfile({required this.repository});

  Future<UserEntity> call(String accessToken) async {
    return await repository.getUserProfile(accessToken);
  }
}