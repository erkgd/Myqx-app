/// Modelo de datos para un elemento del feed de calificaciones
class FeedItem {
  final String id;
  final String contentId; // ID del álbum o canción
  final String contentType; // 'album' o 'track'
  final String title; // Nombre del álbum o canción
  final String artist;
  final String imageUrl;
  final double rating;
  final String? review;
  final String userId;
  final String username;
  final String userImageUrl;
  final DateTime timestamp;

  FeedItem({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.rating,
    this.review,
    required this.userId,
    required this.username,
    required this.userImageUrl,
    required this.timestamp,
  });
  
  /// Método factory para crear un objeto FeedItem desde un mapa JSON
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] ?? '',
      contentId: json['content_id'] ?? '',
      contentType: json['content_type'] ?? 'album',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      review: json['review'],
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      userImageUrl: json['user_image_url'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }
  
  /// Método para convertir el objeto a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'content_type': contentType,
      'title': title,
      'artist': artist,
      'image_url': imageUrl,
      'rating': rating,
      'review': review,
      'user_id': userId,
      'username': username,
      'user_image_url': userImageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
