
enum ArticleType { coiffure, couture }

class ArticleModel {
  final String id;
  final String prestataireId;
  final String titre;
  final String description;
  final double prix;
  final String imageUrl;
  final ArticleType type;
  final Map<String, dynamic>? specs; // Spécifications techniques pour l'essayage

  ArticleModel({
    required this.id,
    required this.prestataireId,
    required this.titre,
    required this.description,
    required this.prix,
    required this.imageUrl,
    required this.type,
    this.specs,
  });
}
