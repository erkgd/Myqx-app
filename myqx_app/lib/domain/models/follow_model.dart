import 'dart:convert';

class Follow {
  final String? id;
  final String followerId;
  final String followingId;
  final DateTime? createdAt;

  Follow({
    this.id,
    required this.followerId,
    required this.followingId,
    this.createdAt,
  });

  Follow copyWith({
    String? id,
    String? followerId,
    String? followingId,
    DateTime? createdAt,
  }) {
    return Follow(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Follow.fromMap(Map<String, dynamic> map) {
    return Follow(
      id: map['id'],
      followerId: map['follower_id'] ?? '',
      followingId: map['following_id'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Follow.fromJson(String source) => Follow.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Follow(id: $id, followerId: $followerId, followingId: $followingId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Follow &&
      other.id == id &&
      other.followerId == followerId &&
      other.followingId == followingId &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      followerId.hashCode ^
      followingId.hashCode ^
      createdAt.hashCode;
  }
}