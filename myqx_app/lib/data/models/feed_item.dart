import 'package:flutter/foundation.dart';

/// Modelo de datos para un elemento del feed de calificaciones
class FeedItem {
  final String id;
  final String contentId; // ID del álbum o canción
  final String contentType; // 'album' o 'track'
  final String title; // Nombre del álbum o canción
  final String artist;
  final String imageUrl;
  final double rating;
  final double normalizedRating; // Rating normalizado (1-5 estrella)
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
    required this.normalizedRating,
    this.review,
    required this.userId,
    required this.username,
    required this.userImageUrl,
    required this.timestamp,
  });
    /// Método factory para crear un objeto FeedItem desde un mapa JSON
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    // Debug para mostrar todas las claves disponibles
    debugPrint('[FEED_ITEM] Procesando item con claves: ${json.keys.join(', ')}');
    
    // Buscar primero en campos con formato snake_case, luego en camelCase
    final id = json['id'] ?? '';
    final contentId = json['content_id'] ?? json['contentId'] ?? '';
    final contentType = json['content_type'] ?? json['contentType'] ?? 'album';
    final title = json['title'] ?? '';
    final artist = json['artist'] ?? '';
    final imageUrl = json['image_url'] ?? json['imageUrl'] ?? '';
    
    // Convertir rating a double
    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    
    // Usar normalizedRating si existe, de lo contrario usar rating normal
    final normalizedRating = (json['normalizedRating'] as num?)?.toDouble() ?? rating;
    
    // Obtener review/comment - intentar con varias posibles claves
    final review = json['review'] ?? json['comment'];
    
    // Debug para el review
    if (review != null && review.isNotEmpty) {
      debugPrint('[FEED_ITEM] ✅ Review encontrado: "$review" para item $id');
    } else {
      debugPrint('[FEED_ITEM] ⚠️ No se encontró review para item $id');
    }
    
    // Información del usuario
    final userId = json['user_id'] ?? json['userId'] ?? '';
    final username = json['username'] ?? '';
    final userImageUrl = json['user_image_url'] ?? json['userImage'] ?? '';
    
    // Fecha - intentar varios formatos
    DateTime timestamp;
    if (json['timestamp'] != null) {
      timestamp = DateTime.parse(json['timestamp']);
    } else if (json['date'] != null) {
      timestamp = DateTime.parse(json['date']);
    } else {
      timestamp = DateTime.now();
    }

    return FeedItem(
      id: id,
      contentId: contentId,
      contentType: contentType,
      title: title,
      artist: artist,
      imageUrl: imageUrl,
      rating: rating,
      normalizedRating: normalizedRating,
      review: review,
      userId: userId,
      username: username,
      userImageUrl: userImageUrl,
      timestamp: timestamp,
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
      'normalizedRating': normalizedRating,
      'review': review,
      'user_id': userId,
      'username': username,
      'user_image_url': userImageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
