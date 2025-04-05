import 'dart:convert';

class Broadcast {
  final String? id;
  final String userId;
  final String musicId;
  final String musicType; // "track" o "album"
  final String musicName;
  final String artistName;
  final String? albumName;
  final String? imageUrl;
  final String? message;
  final double? rating;
  final String? reviewContent;
  final DateTime createdAt;

  Broadcast({
    this.id,
    required this.userId,
    required this.musicId,
    required this.musicType,
    required this.musicName,
    required this.artistName,
    this.albumName,
    this.imageUrl,
    this.message,
    this.rating,
    this.reviewContent,
    required this.createdAt,
  });

  Broadcast copyWith({
    String? id,
    String? userId,
    String? musicId,
    String? musicType,
    String? musicName,
    String? artistName,
    String? albumName,
    String? imageUrl,
    String? message,
    double? rating,
    String? reviewContent,
    DateTime? createdAt,
  }) {
    return Broadcast(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      musicId: musicId ?? this.musicId,
      musicType: musicType ?? this.musicType,
      musicName: musicName ?? this.musicName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      imageUrl: imageUrl ?? this.imageUrl,
      message: message ?? this.message,
      rating: rating ?? this.rating,
      reviewContent: reviewContent ?? this.reviewContent,
      createdAt: createdAt ?? this.createdAt,
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
      'message': message,
      'rating': rating,
      'review_content': reviewContent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Broadcast.fromMap(Map<String, dynamic> map) {
    return Broadcast(
      id: map['id'],
      userId: map['user_id'] ?? '',
      musicId: map['music_id'] ?? '',
      musicType: map['music_type'] ?? 'track',
      musicName: map['music_name'] ?? '',
      artistName: map['artist_name'] ?? '',
      albumName: map['album_name'],
      imageUrl: map['image_url'],
      message: map['message'],
      rating: map['rating']?.toDouble(),
      reviewContent: map['review_content'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Broadcast.fromJson(String source) => Broadcast.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Broadcast(id: $id, userId: $userId, musicId: $musicId, musicType: $musicType, '
           'musicName: $musicName, artistName: $artistName, albumName: $albumName, '
           'imageUrl: $imageUrl, message: $message, rating: $rating, '
           'reviewContent: ${reviewContent != null ? (reviewContent!.length > 20 ? reviewContent!.substring(0, 20) + "..." : reviewContent) : null}, '
           'createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Broadcast &&
      other.id == id &&
      other.userId == userId &&
      other.musicId == musicId &&
      other.musicType == musicType &&
      other.musicName == musicName &&
      other.artistName == artistName &&
      other.albumName == albumName &&
      other.imageUrl == imageUrl &&
      other.message == message &&
      other.rating == rating &&
      other.reviewContent == reviewContent &&
      other.createdAt == createdAt;
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
      message.hashCode ^
      rating.hashCode ^
      reviewContent.hashCode ^
      createdAt.hashCode;
  }
}