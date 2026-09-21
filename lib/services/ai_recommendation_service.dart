import '../models/user_model.dart';
import '../models/article_model.dart';
import 'ai_chat_service.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance = AIRecommendationService._internal();
  factory AIRecommendationService() => _instance;
  AIRecommendationService._internal();

  final AIChatService _aiChatService = AIChatService();

  /// Générer un flux personnalisé "Pour vous" intelligent basé sur le profil de l'utilisateur
  List<ArticleModel> getPersonalizedFeed(List<ArticleModel> allArticles, UserModel? user) {
    if (allArticles.isEmpty) return [];
    if (user == null) {
      // Si non connecté, tri par popularité (likes)
      final sorted = List<ArticleModel>.from(allArticles);
      sorted.sort((a, b) => b.likesCount.compareTo(a.likesCount));
      return sorted;
    }

    final String? morphology = user.morphologieType;
    final String? faceShape = user.formeVisage;

    final scoredArticles = allArticles.map((article) {
      double score = 0;
      final text = "${article.titre} ${article.description} ${article.categorie} ${article.tags.join(' ')}".toLowerCase();

      // 1. Scoring Morphologique pour la Couture
      if (article.type == ArticleType.couture && morphology != null) {
        final morphLower = morphology.toLowerCase();

        if (morphLower.contains("x") || morphLower.contains("sablier")) {
          if (_hasAny(text, ["cintré", "taille haute", "sirène", "ceinture", "corset", "ajusté"])) score += 25;
        } else if (morphLower.contains("a") || morphLower.contains("pyramide")) {
          if (_hasAny(text, ["évasé", "épaulettes", "bustier", "trapèze", "manches ballon", "volume"])) score += 25;
        } else if (morphLower.contains("v")) {
          if (_hasAny(text, ["fendu", "jupe large", "basque", "péplum", "plissé", "décolleté v"])) score += 25;
        } else if (morphLower.contains("h") || morphLower.contains("rectangle")) {
          if (_hasAny(text, ["ceinturé", "drapé", "croisé", "portefeuille", "cache-coeur"])) score += 25;
        } else if (morphLower.contains("o") || morphLower.contains("ronde")) {
          if (_hasAny(text, ["fluide", "droit", "vertical", "tunique", "boubou", "ample"])) score += 25;
        }
      }

      // 2. Scoring Morphologique pour la Coiffure
      if (article.type == ArticleType.coiffure && faceShape != null) {
        final faceLower = faceShape.toLowerCase();

        if (faceLower.contains("ovale")) {
          score += 20; // Convient à la majorité des styles
        } else if (faceLower.contains("rond")) {
          if (_hasAny(text, ["long", "volume haut", "chignon haut", "high puff", "dégradé"])) score += 25;
        } else if (faceLower.contains("carré")) {
          if (_hasAny(text, ["ondulé", "boucles", "mèches", "flou", "bohème", "asymétrique"])) score += 25;
        } else if (faceLower.contains("cœur") || faceLower.contains("coeur")) {
          if (_hasAny(text, ["frange", "mi-long", "carré", "bob", "tresses libres"])) score += 25;
        } else if (faceLower.contains("allongé") || faceLower.contains("rectangle")) {
          if (_hasAny(text, ["volume côté", "mi-long", "tresses larges", "afro"])) score += 25;
        }
      }

      // 3. Score pour popularité et note du prestataire
      score += (article.likesCount * 0.5);
      score += (article.prestataireRating * 2.0);

      return MapEntry(article, score);
    }).toList();

    scoredArticles.sort((a, b) => b.value.compareTo(a.value));
    return scoredArticles.map((e) => e.key).toList();
  }

  bool _hasAny(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }

  // Recommandation ciblée couture
  List<ArticleModel> recommendCouture(List<ArticleModel> allArticles, String? morphology) {
    final coutureOnly = allArticles.where((a) => a.type == ArticleType.couture).toList();
    if (morphology == null) return coutureOnly;

    return getPersonalizedFeed(coutureOnly, UserModel(
      uid: "",
      email: "",
      nom: "",
      prenom: "",
      role: UserRole.client,
      createdAt: DateTime.now(),
      morphologieType: morphology,
    ));
  }

  // Recommandation ciblée coiffure
  List<ArticleModel> recommendCoiffure(List<ArticleModel> allArticles, String? faceShape) {
    final coiffureOnly = allArticles.where((a) => a.type == ArticleType.coiffure).toList();
    if (faceShape == null) return coiffureOnly;

    return getPersonalizedFeed(coiffureOnly, UserModel(
      uid: "",
      email: "",
      nom: "",
      prenom: "",
      role: UserRole.client,
      createdAt: DateTime.now(),
      formeVisage: faceShape,
    ));
  }

  /// Génère un conseil de styliste ultra-personnalisé via l'IA Gemini
  Future<String> getPersonalizedStylistAdvice(UserModel user, List<ArticleModel> topArticles) async {
    final String morphology = user.morphologieType ?? "non définie";
    final String face = user.formeVisage ?? "non définie";
    final String articlesList = topArticles.map((a) => "- ${a.titre} (${a.categorie})").join("\n");

    final prompt = """
      En tant qu'expert styliste pour CamerMode, donne un conseil court (2 phrases max) à ${user.prenom}.
      Sa morphologie est $morphology et son visage est $face.
      Voici les articles que j'ai sélectionnés pour elle/lui :
      $articlesList
      Explique-lui brièvement pourquoi ces choix correspondent à sa silhouette et son style.
    """;

    try {
      return await _aiChatService.getAIResponse(prompt);
    } catch (e) {
      return getMorphologyAdvice(morphology); // Retour au texte classique en cas d'erreur
    }
  }

  String getMorphologyAdvice(String morphology) {
    final m = morphology.toLowerCase();
    if (m.contains("x") || m.contains("sablier")) {
      return "Votre morphologie Sablier (X) est caractérisée par une taille bien marquée. Privilégiez les robes portefeuilles, jupes sirènes et ceintures qui soulignent votre taille.";
    }
    if (m.contains("a") || m.contains("pyramide")) {
      return "Votre silhouette Pyramide (A) est mise en valeur en accentuant le haut du corps avec des manches travaillées, des encolures bateau et des cols bateaux en wax.";
    }
    if (m.contains("v")) {
      return "Pour votre silhouette V, misez sur des jupes amples, des péplums et des fentes qui harmonisent la carrure de vos épaules.";
    }
    if (m.contains("h") || m.contains("rectangle")) {
      return "Pour votre silhouette H, les coupes croisées, les drapés et les ceintures décalées créent de superbes courbes visuelles.";
    }
    return "Privilégiez les étoffes fluides, les décolletés en V et les lignes verticales pour une allure élancée et majestueuse.";
  }
}
