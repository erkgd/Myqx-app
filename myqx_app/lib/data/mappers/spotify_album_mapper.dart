import 'package:myqx_app/data/mappers/spotify_track_mapper.dart';
import 'package:myqx_app/data/models/spotify_album.dart';
import 'package:myqx_app/domain/entities/album.dart';

class SpotifyAlbumMapper {
  /// Convierte un SpotifyAlbum (DTO) a una entidad Album (dominio)
  static Album fromDto(SpotifyAlbum dto) {
    return Album(
      id: dto.id,
      name: dto.name,
      artistName: dto.artistName,
      artistId: dto.artistId,
      coverUrl: dto.coverUrl,
      releaseDate: dto.releaseDate,
      sourceUrl: dto.spotifyUrl,
      totalTracks: dto.totalTracks,
      tracks: dto.tracks != null ? SpotifyTrackMapper.fromDtoList(dto.tracks!) : null,
      rating: dto.rating,
      source: 'spotify',
    );
  }

  /// Convierte una entidad Album a un SpotifyAlbum (DTO)
  static SpotifyAlbum toDto(Album entity) {
    return SpotifyAlbum(
      id: entity.id,
      name: entity.name,
      artistName: entity.artistName,
      artistId: entity.artistId,
      coverUrl: entity.coverUrl ?? '',
      releaseDate: entity.releaseDate,
      spotifyUrl: entity.sourceUrl,
      totalTracks: entity.totalTracks,
      tracks: entity.tracks != null ? SpotifyTrackMapper.toDtoList(entity.tracks!) : null,
      rating: entity.rating,
    );
  }

  /// Convierte una lista de SpotifyAlbum a una lista de Album
  static List<Album> fromDtoList(List<SpotifyAlbum> dtoList) {
    return dtoList.map((dto) => fromDto(dto)).toList();
  }

  /// Convierte una lista de Album a una lista de SpotifyAlbum
  static List<SpotifyAlbum> toDtoList(List<Album> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }
}