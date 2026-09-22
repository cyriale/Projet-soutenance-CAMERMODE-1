import '../models/article_model.dart';
import '../models/user_model.dart';
import 'ai_recommendation_service.dart';
import 'ai_chat_service.dart';

/// SERVICE BACKEND DÉDIÉ AU CLIENT
/// Gère exclusivement les besoins IA et recommandations pour le confort du client.
class ClientAIService {
  final AIRecommendationService _recoEngine = AIRecommendationService();
  final AIChatService _geminiChat = AIChatService();

  /// Récupère les articles "Coups de coeur" adaptés à la morphologie du client
  List<ArticleModel> getPersonalizedRecommendations(List<ArticleModel> allArticles, UserModel client) {
    if (client.role != UserRole.client) return [];
    return _recoEngine.getPersonalizedFeed(allArticles, client).take(5).toList();
  }

  /// Génère le conseil du styliste IA pour le client (utilise la clé Gemini)
  Future<String> getStylistNote(UserModel client, List<ArticleModel> selectedArticles) async {
    if (selectedArticles.isEmpty) return "Complétez votre profil pour des conseils sur mesure.";
    
    return await _recoEngine.getPersonalizedStylistAdvice(client, selectedArticles);
  }

  /// Pose une question directe au styliste IA
  Future<String> askStylistAdvice(String prompt) async {
    return await _geminiChat.getAIResponse(prompt);
  }
}
