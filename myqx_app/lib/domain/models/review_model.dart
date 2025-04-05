import 'dart:convert';

class Review {
  final String? id;
  final String userId;
  final String musicId;
  final String musicType; // "track" o "album"
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    required this.userId,
    required this.musicId,
    required this.musicType,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  Review copyWith({
    String? id,
    String? userId,
    String? musicId,
    String? musicType,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      musicId: musicId ?? this.musicId,
      musicType: musicType ?? this.musicType,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'music_id': musicId,
      'music_type': musicType,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      userId: map['user_id'] ?? '',
      musicId: map['music_id'] ?? '',
      musicType: map['music_type'] ?? 'track',
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, musicId: $musicId, musicType: $musicType, '
           'content: ${content.length > 20 ? content.substring(0, 20) + "..." : content}, '
           'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Review &&
      other.id == id &&
      other.userId == userId &&
      other.musicId == musicId &&
      other.musicType == musicType &&
      other.content == content &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      musicId.hashCode ^
      musicType.hashCode ^
      content.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}