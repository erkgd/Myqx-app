import 'dart:convert';

class Rating {
  final String? id;
  final String userId;
  final String musicId;
  final String musicType; // "track" o "album"
  final double score;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Rating({
    this.id,
    required this.userId,
    required this.musicId,
    required this.musicType,
    required this.score,
    this.createdAt,
    this.updatedAt,
  });

  Rating copyWith({
    String? id,
    String? userId,
    String? musicId,
    String? musicType,
    double? score,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      musicId: musicId ?? this.musicId,
      musicType: musicType ?? this.musicType,
      score: score ?? this.score,
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
      'score': score,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      userId: map['user_id'] ?? '',
      musicId: map['music_id'] ?? '',
      musicType: map['music_type'] ?? 'track',
      score: map['score']?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, musicId: $musicId, musicType: $musicType, score: $score, '
           'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Rating &&
      other.id == id &&
      other.userId == userId &&
      other.musicId == musicId &&
      other.musicType == musicType &&
      other.score == score &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      musicId.hashCode ^
      musicType.hashCode ^
      score.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}