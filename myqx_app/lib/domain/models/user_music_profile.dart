import 'dart:convert';
import 'package:myqx_app/data/models/spotify_album.dart';
import 'package:myqx_app/data/models/spotify_track.dart';

class UserMusicProfile {
  final String userId;
  final List<SpotifyTrack>? topTracks;
  final List<SpotifyAlbum>? topAlbums;
  final SpotifyTrack? starOfTheDay;
  final Map<String, double>? tasteProfile; // Géneros y puntajes
  final DateTime? updatedAt;

  UserMusicProfile({
    required this.userId,
    this.topTracks,
    this.topAlbums,
    this.starOfTheDay,
    this.tasteProfile,
    this.updatedAt,
  });

  UserMusicProfile copyWith({
    String? userId,
    List<SpotifyTrack>? topTracks,
    List<SpotifyAlbum>? topAlbums,
    SpotifyTrack? starOfTheDay,
    Map<String, double>? tasteProfile,
    DateTime? updatedAt,
  }) {
    return UserMusicProfile(
      userId: userId ?? this.userId,
      topTracks: topTracks ?? this.topTracks,
      topAlbums: topAlbums ?? this.topAlbums,
      starOfTheDay: starOfTheDay ?? this.starOfTheDay,
      tasteProfile: tasteProfile ?? this.tasteProfile,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'top_tracks': topTracks?.map((track) => track.toMap()).toList(),
      'top_albums': topAlbums?.map((album) => album.toMap()).toList(),
      'star_of_the_day': starOfTheDay?.toMap(),
      'taste_profile': tasteProfile,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserMusicProfile.fromMap(Map<String, dynamic> map) {
    return UserMusicProfile(
      userId: map['user_id'] ?? '',
      topTracks: map['top_tracks'] != null 
        ? List<SpotifyTrack>.from(map['top_tracks']?.map((x) => SpotifyTrack.fromMap(x)))
        : null,
      topAlbums: map['top_albums'] != null 
        ? List<SpotifyAlbum>.from(map['top_albums']?.map((x) => SpotifyAlbum.fromMap(x)))
        : null,
      starOfTheDay: map['star_of_the_day'] != null 
        ? SpotifyTrack.fromMap(map['star_of_the_day']) 
        : null,
      tasteProfile: map['taste_profile'] != null 
        ? Map<String, double>.from(map['taste_profile']) 
        : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserMusicProfile.fromJson(String source) => UserMusicProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserMusicProfile(userId: $userId, topTracks: ${topTracks?.length}, topAlbums: ${topAlbums?.length}, '
           'starOfTheDay: ${starOfTheDay?.name}, tasteProfile: $tasteProfile, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserMusicProfile &&
      other.userId == userId &&
      _listEquals(other.topTracks, topTracks) &&
      _listEquals(other.topAlbums, topAlbums) &&
      other.starOfTheDay == starOfTheDay &&
      _mapEquals(other.tasteProfile, tasteProfile) &&
      other.updatedAt == updatedAt;
  }
  
  bool _listEquals<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
  
  bool _mapEquals<K, V>(Map<K, V>? map1, Map<K, V>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      topTracks.hashCode ^
      topAlbums.hashCode ^
      starOfTheDay.hashCode ^
      tasteProfile.hashCode ^
      updatedAt.hashCode;
  }
}