import 'package:myqx_app/data/models/spotify_models.dart';
import 'package:myqx_app/domain/entities/user.dart';

class SpotifyUserMapper {
  /// Convierte un SpotifyUser (DTO) a una entidad UserEntity (dominio)
  static UserEntity fromDto(SpotifyUser dto) {
    return UserEntity(
      id: dto.id,
      displayName: dto.displayName,
      email: dto.email,
      imageUrl: dto.imageUrl,
      sourceUrl: dto.spotifyUrl,
      followers: dto.followers,
      source: 'spotify',
    );
  }

  /// Convierte una entidad UserEntity a un SpotifyUser (DTO)
  static SpotifyUser toDto(UserEntity entity) {
    return SpotifyUser(
      id: entity.id,
      displayName: entity.displayName,
      email: entity.email,
      imageUrl: entity.imageUrl,
      spotifyUrl: entity.sourceUrl ?? '',
      followers: entity.followers ?? 0,
    );
  }

  /// Convierte una lista de SpotifyUser a una lista de UserEntity
  static List<UserEntity> fromDtoList(List<SpotifyUser> dtoList) {
    return dtoList.map((dto) => fromDto(dto)).toList();
  }

  /// Convierte una lista de UserEntity a una lista de SpotifyUser
  static List<SpotifyUser> toDtoList(List<UserEntity> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }
}