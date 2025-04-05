import 'dart:convert';

class ListeningHistory {
  final String? id;
  final String userId;
  final String musicId;
  final String musicType; // "track" o "album"
  final String musicName;
  final String artistName;
  final String? albumName;
  final String? imageUrl;
  final DateTime listenedAt;

  ListeningHistory({
    this.id,
    required this.userId,
    required this.musicId,
    required this.musicType,
    required this.musicName,
    required this.artistName,
    this.albumName,
    this.imageUrl,
    required this.listenedAt,
  });

  ListeningHistory copyWith({
    String? id,
    String? userId,
    String? musicId,
    String? musicType,
    String? musicName,
    String? artistName,
    String? albumName,
    String? imageUrl,
    DateTime? listenedAt,
  }) {
    return ListeningHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      musicId: musicId ?? this.musicId,
      musicType: musicType ?? this.musicType,
      musicName: musicName ?? this.musicName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      imageUrl: imageUrl ?? this.imageUrl,
      listenedAt: listenedAt ?? this.listenedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'music_id': musicId,
      'music_type': musicType,
      'music_name': musicName,
      'artist_name': artistName,
      'album_name': albumName,
      'image_url': imageUrl,
      'listened_at': listenedAt.toIso8601String(),
    };
  }

  factory ListeningHistory.fromMap(Map<String, dynamic> map) {
    return ListeningHistory(
      id: map['id'],
      userId: map['user_id'] ?? '',
      musicId: map['music_id'] ?? '',
      musicType: map['music_type'] ?? 'track',
      musicName: map['music_name'] ?? '',
      artistName: map['artist_name'] ?? '',
      albumName: map['album_name'],
      imageUrl: map['image_url'],
      listenedAt: map['listened_at'] != null 
          ? DateTime.parse(map['listened_at']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ListeningHistory.fromJson(String source) => ListeningHistory.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ListeningHistory(id: $id, userId: $userId, musicId: $musicId, musicType: $musicType, '
           'musicName: $musicName, artistName: $artistName, albumName: $albumName, '
           'imageUrl: $imageUrl, listenedAt: $listenedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ListeningHistory &&
      other.id == id &&
      other.userId == userId &&
      other.musicId == musicId &&
      other.musicType == musicType &&
      other.musicName == musicName &&
      other.artistName == artistName &&
      other.albumName == albumName &&
      other.imageUrl == imageUrl &&
      other.listenedAt == listenedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      musicId.hashCode ^
      musicType.hashCode ^
      musicName.hashCode ^
      artistName.hashCode ^
      albumName.hashCode ^
      imageUrl.hashCode ^
      listenedAt.hashCode;
  }
}