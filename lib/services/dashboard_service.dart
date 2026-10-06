
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../models/reservation_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import 'ai_recommendation_service.dart';
import 'auth_service.dart';
import 'chat_service.dart';

class DashboardService extends ChangeNotifier {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;

  final AIRecommendationService _aiService = AIRecommendationService();
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DashboardService._internal() {
    _initializeData();
    _loadUserProfile();
  }

  UserModel? _currentUserProfile;
  UserModel? get currentUserProfile => _currentUserProfile;

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUserProfile = UserModel.fromMap(doc.data()!, user.uid);
        notifyListeners();
      }
    }
  }

  // Articles & Publications
  List<ArticleModel> _articles = [];
  List<ArticleModel> get articles => _articles;

  // Sauvegardes d'images (Mes sauvegardes - Distinct des favoris !)
  final Set<String> _savedArticleIds = {};
  Set<String> get savedArticleIds => _savedArticleIds;

  // Prestataires favoris (ID)
  final Set<String> _favoritePrestataireIds = {"p1", "p2"};
  Set<String> get favoritePrestataireIds => _favoritePrestataireIds;

  // Réservations
  final List<ReservationModel> _reservations = [];
  List<ReservationModel> get reservations => _reservations;

  // Avis
  final List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  // Essayages sauvegardés
  final List<Map<String, dynamic>> _savedTryOns = [];
  List<Map<String, dynamic>> get savedTryOns => _savedTryOns;

  // Profil & Préférences de morphologie
  Map<String, dynamic> userPreferences = {
    "morphologie": "Sablier (X)",
    "taille": 172.0,
    "tourPoitrine": 92.0,
    "tourTaille": 68.0,
    "tourHanche": 100.0,
    "typeCheveux": "Crépus (4C)",
    "formeVisage": "Ovale",
    "styles": ["Wax Moderne", "Afro-Chic", "Toghu Royal", "Tresses Goddess"],
  };

  void updateUserMeasurements(Map<String, dynamic> data) {
    userPreferences.addAll(data);
    notifyListeners();
  }

  // Articles recommandés par l'IA
  List<ArticleModel> get recommendedArticles {
    if (_currentUserProfile == null) return _articles;
    
    final couture = _aiService.recommendCouture(_articles, _currentUserProfile!.morphologieType);
    final coiffure = _aiService.recommendCoiffure(_articles, _currentUserProfile!.formeVisage);
    
    return [...couture, ...coiffure]..shuffle();
  }

  // Compatibilité avec les anciens écrans pour le chat
  Future<String> getOrCreateConversation({
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) async {
    if (_currentUserProfile == null) await _loadUserProfile();
    if (_currentUserProfile == null) return "";

    return await _chatService.getOrCreateConversation(
      client: _currentUserProfile!,
      prestataireId: prestataireId,
      prestataireNom: prestataireNom,
      prestatairePhoto: prestatairePhoto,
      articleRefTitre: articleRefTitre,
      articleRefImageUrl: articleRefImageUrl,
    );
  }

  void _initializeData() {
    _articles = [
      ArticleModel(
        id: "art-1",
        prestataireId: "p1",
        prestataireNom: "Atelier Cyriale Couture",
        prestatairePhoto: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04",
        prestataireRating: 4.9,
        prestataireAvisCount: 128,
        prestataireVerified: true,
        prestataireAdresse: "Akwa, Boulevard de la Liberté, Douala",
        prestataireDistance: "1.8 km",
        prestationADomicile: true,
        titre: "Robe Sirène Wax Ankara Royale",
        description: "Sublime robe sirène confectionnée avec un tissu Wax Ankara haut de gamme. Décolleté travaillé, finitions brodées à la main avec fente élégante. Idéale pour galas, mariages et cérémonies prestigieuses.",
        prix: 45000,
        imageUrl: "https://images.unsplash.com/photo-1590736969955-71cc94801759",
        galleryImages: [
          "https://images.unsplash.com/photo-1590736969955-71cc94801759",
          "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae",
        ],
        type: ArticleType.couture,
        categorie: "Robes de Soirée",
        couleursDisponibles: ["Rouge Rubis", "Or Doré", "Bleu Indigo", "Noir Chic", "Vert Forêt"],
        taillesDisponibles: ["36 (S)", "38 (M)", "40 (L)", "42 (XL)", "Sur-mesure"],
        likesCount: 342,
        isLiked: false,
        isFavorite: true,
        isSaved: true,
        isPrestation: false,
        tags: ["Soirée", "Wax", "Mariage", "Cérémonie", "sirène", "cintré"],
      ),
      ArticleModel(
        id: "art-2",
        prestataireId: "p2",
        prestataireNom: "Afro Queen Hair Studio",
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e",
        prestataireRating: 4.8,
        prestataireAvisCount: 95,
        prestataireVerified: true,
        prestataireAdresse: "Bastos, Yaoundé",
        prestataireDistance: "3.4 km",
        prestationADomicile: true,
        titre: "Tresses Knotless Goddess Braids",
        description: "Tresses sans nœuds Goddess Braids ultra légères et élégantes avec mèches ondulées bohèmes. Protection capillaire soignée, fixation durable sans traction excessive sur le cuir chevelu.",
        prix: 25000,
        imageUrl: "https://images.unsplash.com/photo-1607990281513-2c110a25bd8c",
        type: ArticleType.coiffure,
        categorie: "Tresses & Nattes",
        couleursDisponibles: ["Noir Naturel 1B", "Châtain Foncé 2", "Miel Dégradé 27", "Bordeaux 99J"],
        taillesDisponibles: ["Longueur Épaules", "Longueur Mi-dos", "Longueur Taille"],
        likesCount: 512,
        isLiked: true,
        isFavorite: true,
        isSaved: false,
        isPrestation: true,
        tags: ["Tresses", "Goddess", "Protective Style", "Bohème", "long", "ondulé"],
      ),
    ];

    _savedArticleIds.addAll(["art-1"]);

    _reservations.addAll([
      ReservationModel(
        id: "res-1",
        userId: "user-1",
        prestataireId: "p2",
        prestataireNom: "Afro Queen Hair Studio",
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=400&q=80",
        prestataireAdresse: "Bastos, Yaoundé",
        serviceTitre: "Tresses Knotless Goddess Braids",
        articleImageUrl: "https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?auto=format&fit=crop&w=800&q=80",
        date: DateTime.now().subtract(const Duration(days: 4)),
        heure: "14:30",
        lieuType: LieuPrestation.auSalon,
        notes: "Mèches ondulées couleur 1B prévues",
        status: ReservationStatus.terminee,
        prixEstime: 25000,
        hasReview: true,
      ),
    ]);

    _reviews.add(
      ReviewModel(
        id: "rev-1",
        reservationId: "res-1",
        prestataireId: "p2",
        userId: "user-1",
        userNom: "Utilisateur",
        rating: 5.0,
        commentaire: "Prestation impeccable !",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        serviceTitre: "Tresses Knotless Goddess Braids",
        photoUrl: "https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?auto=format&fit=crop&w=400&q=80",
      ),
    );
  }

  // --- ACTIONS LIKES ---
  void toggleLike(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final art = _articles[index];
      final newIsLiked = !art.isLiked;
      final newCount = newIsLiked ? art.likesCount + 1 : art.likesCount - 1;
      _articles[index] = art.copyWith(
        isLiked: newIsLiked,
        likesCount: newCount < 0 ? 0 : newCount,
      );
      notifyListeners();
    }
  }

  // --- ACTIONS FAVORIS ---
  void toggleFavorite(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final art = _articles[index];
      _articles[index] = art.copyWith(isFavorite: !art.isFavorite);
      notifyListeners();
    }
  }

  void toggleFavoritePrestataire(String prestataireId) {
    if (_favoritePrestataireIds.contains(prestataireId)) {
      _favoritePrestataireIds.remove(prestataireId);
    } else {
      _favoritePrestataireIds.add(prestataireId);
    }
    notifyListeners();
  }

  // --- ACTIONS ENREGISTREMENTS D'IMAGES (Mes Sauvegardes) ---
  void toggleSaveImage(String articleId) {
    if (_savedArticleIds.contains(articleId)) {
      _savedArticleIds.remove(articleId);
    } else {
      _savedArticleIds.add(articleId);
    }
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        isSaved: _savedArticleIds.contains(articleId),
      );
    }
    notifyListeners();
  }

  void cancelReservation(String reservationId) {
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(status: ReservationStatus.annulee);
      notifyListeners();
    }
  }

  // --- ACTIONS AVIS ---
  void addReview({
    required String reservationId,
    required String prestataireId,
    required double rating,
    required String commentaire,
    required String serviceTitre,
    String? photoUrl,
  }) {
    final newReview = ReviewModel(
      id: "rev-${DateTime.now().millisecondsSinceEpoch}",
      reservationId: reservationId,
      prestataireId: prestataireId,
      userId: _authService.currentUser?.uid ?? "user-1",
      userNom: _currentUserProfile?.prenom ?? "Utilisateur",
      rating: rating,
      commentaire: commentaire,
      createdAt: DateTime.now(),
      serviceTitre: serviceTitre,
      photoUrl: photoUrl,
    );

    _reviews.insert(0, newReview);

    final resIndex = _reservations.indexWhere((r) => r.id == reservationId);
    if (resIndex != -1) {
      _reservations[resIndex] = _reservations[resIndex].copyWith(hasReview: true);
    }

    notifyListeners();
  }

  void deleteReview(String reviewId) {
    _reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }

  // --- ACTIONS ESSAYAGE VIRTUEL ---
  void saveTryOnResult({
    required String articleId,
    required String articleTitre,
    required String colorName,
    required String size,
    required String imageUrl,
  }) {
    _savedTryOns.insert(0, {
      "id": "try-${DateTime.now().millisecondsSinceEpoch}",
      "articleId": articleId,
      "articleTitre": articleTitre,
      "colorName": colorName,
      "size": size,
      "imageUrl": imageUrl,
      "date": DateTime.now(),
    });
    notifyListeners();
  }
}
