import 'package:myqx_app/data/models/spotify_track.dart';
import 'package:myqx_app/domain/entities/track.dart';

class SpotifyTrackMapper {
  /// Convierte un SpotifyTrack (DTO) a una entidad Track (dominio)
  static Track fromDto(SpotifyTrack dto) {
    return Track(
      id: dto.id,
      name: dto.name,
      artistName: dto.artistName,
      albumName: dto.albumName,
      imageUrl: dto.imageUrl,
      sourceUrl: dto.spotifyUrl,
      albumId: dto.albumId,
      source: 'spotify',
    );
  }

  /// Convierte una entidad Track a un SpotifyTrack (DTO)
  static SpotifyTrack toDto(Track entity) {
    return SpotifyTrack(
      id: entity.id,
      name: entity.name,
      artistName: entity.artistName,
      albumName: entity.albumName,
      imageUrl: entity.imageUrl,
      spotifyUrl: entity.sourceUrl,
      albumId: entity.albumId,
    );
  }

  /// Convierte una lista de SpotifyTrack a una lista de Track
  static List<Track> fromDtoList(List<SpotifyTrack> dtoList) {
    return dtoList.map((dto) => fromDto(dto)).toList();
  }

  /// Convierte una lista de Track a una lista de SpotifyTrack
  static List<SpotifyTrack> toDtoList(List<Track> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }
}