class UserEntity {
  final String id;
  final String displayName;
  final String? email;
  final String? imageUrl;
  final String? sourceUrl; // URL de plataforma externa (Spotify, etc.)
  final int? followers;
  final String source; // Identificador de la fuente (ej: "spotify", "myqx")

  UserEntity({
    required this.id,
    required this.displayName,
    this.email,
    this.imageUrl,
    this.sourceUrl,
    this.followers,
    required this.source,
  });

  @override
  String toString() {
    return 'UserEntity(id: $id, displayName: $displayName, source: $source)';
  }
}