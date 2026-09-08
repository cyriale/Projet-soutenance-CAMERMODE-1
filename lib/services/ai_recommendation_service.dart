import '../models/article_model.dart';

class AIRecommendationService {
  // Logique de recommandation basée sur la morphologie corporelle
  List<ArticleModel> recommendCouture(List<ArticleModel> allArticles, String? morphology) {
    if (morphology == null) return allArticles.where((a) => a.type == ArticleType.couture).toList();

    final articlesWithScores = allArticles.where((a) => a.type == ArticleType.couture).map((article) {
      double score = 0;
      final tags = article.tags.map((t) => t.toLowerCase()).toList();

      if (morphology.contains("X")) { // Sablier
        if (tags.contains("cintré") || tags.contains("taille haute") || tags.contains("sirène")) score += 10;
      } else if (morphology.contains("A")) { // Pyramide
        if (tags.contains("évasé") || tags.contains("épaulettes") || tags.contains("bustier")) score += 10;
      } else if (morphology.contains("V")) { // Pyramide inversée
        if (tags.contains("fendu") || tags.contains("jupe large") || tags.contains("basque")) score += 10;
      } else if (morphology.contains("H")) { // Rectangle
        if (tags.contains("ceinture") || tags.contains("péplum") || tags.contains("croisé")) score += 10;
      } else if (morphology.contains("O")) { // Ronde
        if (tags.contains("fluide") || tags.contains("droit") || tags.contains("vertical")) score += 10;
      }

      // Bonus pour les likes
      score += article.likesCount / 100;

      return MapEntry(article, score);
    }).toList();

    // Tri par score décroissant
    articlesWithScores.sort((a, b) => b.value.compareTo(a.value));

    // Extraction des articles triés
    return articlesWithScores.map((e) => e.key).toList();
  }

  // Logique de recommandation basée sur la forme du visage
  List<ArticleModel> recommendCoiffure(List<ArticleModel> allArticles, String? faceShape) {
    if (faceShape == null) return allArticles.where((a) => a.type == ArticleType.coiffure).toList();

    final articlesWithScores = allArticles.where((a) => a.type == ArticleType.coiffure).map((article) {
      double score = 0;
      final tags = article.tags.map((t) => t.toLowerCase()).toList();

      if (faceShape.toLowerCase() == "ovale") {
        score += 10; // Convient à tout
      } else if (faceShape.toLowerCase() == "rond") {
        if (tags.contains("long") || tags.contains("volume haut") || tags.contains("dégradé")) score += 10;
      } else if (faceShape.toLowerCase() == "carré") {
        if (tags.contains("boucles") || tags.contains("ondulé") || tags.contains("mèches")) score += 10;
      }

      return MapEntry(article, score);
    }).toList();

    // Tri par score décroissant
    articlesWithScores.sort((a, b) => b.value.compareTo(a.value));

    // Extraction des articles triés
    return articlesWithScores.map((e) => e.key).toList();
  }
}
