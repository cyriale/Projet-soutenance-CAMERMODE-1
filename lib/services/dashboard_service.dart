
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../models/reservation_model.dart';
import '../models/review_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'ai_recommendation_service.dart';
import 'auth_service.dart';

class DashboardService extends ChangeNotifier {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;

  final AIRecommendationService _aiService = AIRecommendationService();
  final AuthService _authService = AuthService();
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

  // Articles recommandés par l'IA
  List<ArticleModel> get recommendedArticles {
    if (_currentUserProfile == null) return _articles;
    
    final couture = _aiService.recommendCouture(_articles, _currentUserProfile!.morphologieType);
    final coiffure = _aiService.recommendCoiffure(_articles, _currentUserProfile!.formeVisage);
    
    return [...couture, ...coiffure]..shuffle();
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

  // Conversations & Messages
  final List<ConversationModel> _conversations = [];
  List<ConversationModel> get conversations => _conversations;
  final Map<String, List<ChatMessageModel>> _messagesByConv = {};

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

  void _initializeData() {
    _articles = [
      ArticleModel(
        id: "art-1",
        prestataireId: "p1",
        prestataireNom: "Atelier Cyriale Couture",
        prestatairePhoto: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.9,
        prestataireAvisCount: 128,
        prestataireVerified: true,
        prestataireAdresse: "Akwa, Boulevard de la Liberté, Douala",
        prestataireDistance: "1.8 km",
        prestationADomicile: true,
        titre: "Robe Sirène Wax Ankara Royale",
        description: "Sublime robe sirène confectionnée avec un tissu Wax Ankara haut de gamme. Décolleté travaillé, finitions brodées à la main avec fente élégante. Idéale pour galas, mariages et cérémonies prestigieuses.",
        prix: 45000,
        imageUrl: "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=800&q=80",
        galleryImages: [
          "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=800&q=80",
          "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80",
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
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.8,
        prestataireAvisCount: 95,
        prestataireVerified: true,
        prestataireAdresse: "Bastos, Yaoundé",
        prestataireDistance: "3.4 km",
        prestationADomicile: true,
        titre: "Tresses Knotless Goddess Braids",
        description: "Tresses sans nœuds Goddess Braids ultra légères et élégantes avec mèches ondulées bohèmes. Protection capillaire soignée, fixation durable sans traction excessive sur le cuir chevelu.",
        prix: 25000,
        imageUrl: "https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?auto=format&fit=crop&w=800&q=80",
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
      ArticleModel(
        id: "art-3",
        prestataireId: "p1",
        prestataireNom: "Atelier Cyriale Couture",
        prestatairePhoto: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.9,
        prestataireAvisCount: 128,
        prestataireVerified: true,
        prestataireAdresse: "Akwa, Douala",
        prestataireDistance: "1.8 km",
        prestationADomicile: true,
        titre: "Ensemble Veste Tailleur & Pantalon Kente",
        description: "Costume deux pièces contemporain combinant coupe italienne cintrée et motifs géométriques Kente. Tissu respirant, poches plaquées et doublure en soie satinée.",
        prix: 65000,
        imageUrl: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.couture,
        categorie: "Tailleur & Chic",
        couleursDisponibles: ["Bleu & Or", "Noir & Ocre", "Vert & Pourpre"],
        taillesDisponibles: ["S", "M", "L", "XL", "Sur-mesure"],
        likesCount: 219,
        isLiked: false,
        isFavorite: false,
        isSaved: true,
        isPrestation: false,
        tags: ["Business", "Kente", "Afro-Chic", "Moderne"],
      ),
      ArticleModel(
        id: "art-4",
        prestataireId: "p3",
        prestataireNom: "Maison du Bazin & Soie",
        prestatairePhoto: "https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.7,
        prestataireAvisCount: 64,
        prestataireVerified: true,
        prestataireAdresse: "Bonapriso, Douala",
        prestataireDistance: "4.1 km",
        prestationADomicile: false,
        titre: "Grand Boubou Bazin Getzner VIP Brodé",
        description: "Boubou traditionnel de grand luxe en Bazin Getzner 100% authentique. Broderies volumétriques dorées sur le col et les manches, tombé majestueux pour les grandes réceptions et mariages.",
        prix: 85000,
        imageUrl: "https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.couture,
        categorie: "Boubous & Cérémonie",
        couleursDisponibles: ["Blanc Nacré", "Bleu Ciel", "Violet Impérial", "Vert Menthe"],
        taillesDisponibles: ["Taille Unique Grand Tombé", "Sur-mesure"],
        likesCount: 418,
        isLiked: false,
        isFavorite: false,
        isSaved: false,
        isPrestation: false,
        tags: ["Bazin", "Getzner", "Cérémonie", "Tradition"],
      ),
      ArticleModel(
        id: "art-5",
        prestataireId: "p2",
        prestataireNom: "Afro Queen Hair Studio",
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.8,
        prestataireAvisCount: 95,
        prestataireVerified: true,
        prestataireAdresse: "Bastos, Yaoundé",
        prestataireDistance: "3.4 km",
        prestationADomicile: true,
        titre: "Coupe Afro Nappy & Soin Hydratant",
        description: "Sculpture volumétrique sur cheveux naturels crépus (type 4C/4B) avec dégradé soigné et définition des boucles. Bain d'huiles végétales et beurres de karité purs.",
        prix: 18000,
        imageUrl: "https://images.unsplash.com/photo-1523824921871-d6f1a15151f1?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.coiffure,
        categorie: "Cheveux Naturels",
        couleursDisponibles: ["Noir Ébène", "Chocolat Doux", "Miel Caramel", "Roux Flamboyant"],
        taillesDisponibles: ["Court Sculpté", "Volume Moyen", "Maxi Volume"],
        likesCount: 683,
        isLiked: true,
        isFavorite: false,
        isSaved: true,
        isPrestation: true,
        tags: ["Nappy", "Afro", "Soin", "Naturel"],
      ),
      ArticleModel(
        id: "art-6",
        prestataireId: "p4",
        prestataireNom: "Ewondo Style & Création",
        prestatairePhoto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.6,
        prestataireAvisCount: 42,
        prestataireVerified: true,
        prestataireAdresse: "Deido, Douala",
        prestataireDistance: "5.0 km",
        prestationADomicile: true,
        titre: "Robe de Cérémonie Toghu Grassfields",
        description: "Robe d'apparat en velours noir lourd brodée aux fils traditionnels rouge, jaune et blanc de l'Ouest Cameroun. Coupe princesse évasée avec col montant.",
        prix: 55000,
        imageUrl: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.couture,
        categorie: "Tradition & Héritage",
        couleursDisponibles: ["Noir & Broderie Rouge", "Noir & Broderie Or", "Bleu Nuit & Broderie Blanche"],
        taillesDisponibles: ["S", "M", "L", "XL", "Sur-mesure"],
        likesCount: 290,
        isLiked: false,
        isFavorite: false,
        isSaved: false,
        isPrestation: false,
        tags: ["Toghu", "Cameroun", "Héritage", "Couture"],
      ),
      ArticleModel(
        id: "art-7",
        prestataireId: "p2",
        prestataireNom: "Afro Queen Hair Studio",
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.8,
        prestataireAvisCount: 95,
        prestataireVerified: true,
        prestataireAdresse: "Bastos, Yaoundé",
        prestataireDistance: "3.4 km",
        prestationADomicile: true,
        titre: "Butterfly Locs Stylisées Bohème",
        description: "Pose professionnelle de Butterfly Locs douces et texturées avec finition perlée ou dorée. Coiffure protectrice légère, souple et durable jusqu'à 8 semaines.",
        prix: 30000,
        imageUrl: "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.coiffure,
        categorie: "Locks & Twists",
        couleursDisponibles: ["Noir Intense", "Châtain Doré", "Ombré Miel 27"],
        taillesDisponibles: ["14 pouces", "18 pouces", "24 pouces"],
        likesCount: 388,
        isLiked: false,
        isFavorite: true,
        isSaved: true,
        isPrestation: true,
        tags: ["Locks", "Butterfly", "Coiffure", "Protectrice"],
      ),
      ArticleModel(
        id: "art-8",
        prestataireId: "p1",
        prestataireNom: "Atelier Cyriale Couture",
        prestatairePhoto: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.9,
        prestataireAvisCount: 128,
        prestataireVerified: true,
        prestataireAdresse: "Akwa, Douala",
        prestataireDistance: "1.8 km",
        prestationADomicile: true,
        titre: "Robe Peplum Wax & Jupe Fendue",
        description: "Ensemble deux pièces peplum en wax hollandais de première qualité. Taille ajustée avec basque évasée et jupe crayon mi-longue à fente d'aisance.",
        prix: 38000,
        imageUrl: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.couture,
        categorie: "Robes de Soirée",
        couleursDisponibles: ["Jaune Solaire & Bleu", "Rouge Corail", "Vert Émeraude"],
        taillesDisponibles: ["S", "M", "L", "XL", "Sur-mesure"],
        likesCount: 470,
        isLiked: true,
        isFavorite: true,
        isSaved: true,
        isPrestation: false,
        tags: ["Peplum", "Wax", "Élégance", "Chic"],
      ),
      ArticleModel(
        id: "art-9",
        prestataireId: "p2",
        prestataireNom: "Afro Queen Hair Studio",
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.8,
        prestataireAvisCount: 95,
        prestataireVerified: true,
        prestataireAdresse: "Bastos, Yaoundé",
        prestataireDistance: "3.4 km",
        prestationADomicile: true,
        titre: "Nattes Fulani Braids avec Caoris",
        description: "Tresses royales inspirées des Fulani Braids avec motifs géométriques au sommet de la tête et perles en bois et caoris naturels. Finitions parfaites sans douleur.",
        prix: 28000,
        imageUrl: "https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.coiffure,
        categorie: "Tresses & Nattes",
        couleursDisponibles: ["Noir Naturel 1B", "Mèches Cuivrées", "Dégradé Chocolat"],
        taillesDisponibles: ["Mi-dos", "Taille"],
        likesCount: 615,
        isLiked: false,
        isFavorite: true,
        isSaved: false,
        isPrestation: true,
        tags: ["Fulani", "Caoris", "Tradition", "Tresses"],
      ),
      ArticleModel(
        id: "art-10",
        prestataireId: "p4",
        prestataireNom: "Ewondo Style & Création",
        prestatairePhoto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80",
        prestataireRating: 4.6,
        prestataireAvisCount: 42,
        prestataireVerified: true,
        prestataireAdresse: "Deido, Douala",
        prestataireDistance: "5.0 km",
        prestationADomicile: true,
        titre: "Chemise Homme Wax & Broderie Ndop",
        description: "Chemise masculine ajustée en coton peigné avec col officier et incrustations de tissu traditionnel Ndop sur la patte de boutonnage. Confort exceptionnel et allure soignée.",
        prix: 32000,
        imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80",
        type: ArticleType.couture,
        categorie: "Tailleur & Chic",
        couleursDisponibles: ["Blanc & Ndop Bleu", "Noir & Ndop Indigo", "Bleu Ciel"],
        taillesDisponibles: ["M", "L", "XL", "XXL", "Sur-mesure"],
        likesCount: 334,
        isLiked: false,
        isFavorite: false,
        isSaved: true,
        isPrestation: false,
        tags: ["Homme", "Ndop", "Tradition", "Chemise"],
      ),
    ];

    _savedArticleIds.addAll(["art-1", "art-3", "art-5", "art-7", "art-8", "art-10"]);

    // Exemples de réservations avec photos réelles
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
      ReservationModel(
        id: "res-2",
        userId: "user-1",
        prestataireId: "p1",
        prestataireNom: "Atelier Cyriale Couture",
        prestatairePhoto: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=400&q=80",
        prestataireAdresse: "Akwa, Douala",
        serviceTitre: "Prise de mesures & Confection Robe Wax",
        articleImageUrl: "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=800&q=80",
        date: DateTime.now().add(const Duration(days: 3)),
        heure: "10:00",
        lieuType: LieuPrestation.aDomicile,
        adresseClient: "Bonamoussadi, Résidence Les Palmiers",
        notes: "Apporter échantillons de tissu wax rouge et bleu",
        status: ReservationStatus.acceptee,
        prixEstime: 45000,
        hasReview: false,
      ),
      ReservationModel(
        id: "res-3",
        userId: "user-1",
        prestataireId: "p3",
        prestataireNom: "Maison du Bazin & Soie",
        prestatairePhoto: "https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?auto=format&fit=crop&w=400&q=80",
        prestataireAdresse: "Bonapriso, Douala",
        serviceTitre: "Ajustement Grand Boubou Bazin VIP",
        articleImageUrl: "https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?auto=format&fit=crop&w=800&q=80",
        date: DateTime.now().add(const Duration(days: 6)),
        heure: "16:00",
        lieuType: LieuPrestation.auSalon,
        notes: "Vérifier la longueur de manche et l'encolure",
        status: ReservationStatus.enAttente,
        prixEstime: 15000,
        hasReview: false,
      ),
    ]);

    // Avis initial vérifié
    _reviews.add(
      ReviewModel(
        id: "rev-1",
        reservationId: "res-1",
        prestataireId: "p2",
        userId: "user-1",
        userNom: "Mercy Cyriale",
        rating: 5.0,
        commentaire: "Prestation impeccable ! Les tresses sont magnifiques, très légères et ne tirent pas du tout sur le cuir chevelu. Très ponctuelle et salon très agréable.",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        serviceTitre: "Tresses Knotless Goddess Braids",
        photoUrl: "https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?auto=format&fit=crop&w=400&q=80",
      ),
    );

    // Initial conversations
    _conversations.addAll([
      ConversationModel(
        id: "conv-1",
        prestataireId: "p1",
        prestataireNom: "Atelier Cyriale Couture",
        prestatairePhoto: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=400&q=80",
        prestataireVerified: true,
        lastMessage: "Bonjour ! Votre rendez-vous pour la prise de mesures est bien noté pour ce jeudi.",
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 1,
        articleRefTitre: "Robe Sirène Wax Ankara Royale",
        articleRefImageUrl: "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=800&q=80",
      ),
      ConversationModel(
        id: "conv-2",
        prestataireId: "p2",
        prestataireNom: "Afro Queen Hair Studio",
        prestatairePhoto: "https://images.unsplash.com/photo-1589156280159-27698a70f29e?auto=format&fit=crop&w=400&q=80",
        prestataireVerified: true,
        lastMessage: "Merci pour votre avis 5 étoiles ! Au plaisir de vous revoir au salon.",
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        articleRefTitre: "Tresses Knotless Goddess Braids",
      ),
    ]);

    _messagesByConv["conv-1"] = [
      ChatMessageModel(
        id: "m1",
        senderId: "user-1",
        text: "Bonjour Atelier Cyriale, je suis intéressée par la Robe Sirène Wax Ankara. Est-il possible de la réaliser en sur-mesure d'ici la fin du mois ?",
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isFromUser: true,
        articleRefTitre: "Robe Sirène Wax Ankara Royale",
        articleRefImageUrl: "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=800&q=80",
      ),
      ChatMessageModel(
        id: "m2",
        senderId: "p1",
        text: "Bonjour ! Absolument, nous travaillons sur-mesure avec grand plaisir. Le délai standard est de 7 jours.",
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isFromUser: false,
      ),
      ChatMessageModel(
        id: "m3",
        senderId: "p1",
        text: "Bonjour ! Votre rendez-vous pour la prise de mesures est bien noté pour ce jeudi.",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isFromUser: false,
      ),
    ];
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

  // --- ACTIONS RÉSERVATIONS ---
  void createReservation({
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    required String prestataireAdresse,
    required String serviceTitre,
    String? articleImageUrl,
    required DateTime date,
    required String heure,
    required LieuPrestation lieuType,
    required String adresseClient,
    required String notes,
    required double prixEstime,
  }) {
    final newRes = ReservationModel(
      id: "res-${DateTime.now().millisecondsSinceEpoch}",
      userId: "user-1",
      prestataireId: prestataireId,
      prestataireNom: prestataireNom,
      prestatairePhoto: prestatairePhoto,
      prestataireAdresse: prestataireAdresse,
      serviceTitre: serviceTitre,
      articleImageUrl: articleImageUrl,
      date: date,
      heure: heure,
      lieuType: lieuType,
      adresseClient: adresseClient,
      notes: notes,
      status: ReservationStatus.enAttente,
      prixEstime: prixEstime,
      hasReview: false,
    );
    _reservations.insert(0, newRes);
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
      userId: "user-1",
      userNom: "Mercy Cyriale",
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

  // --- ACTIONS MESSAGERIE ---
  String getOrCreateConversation({
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) {
    final existing = _conversations.firstWhere(
      (c) => c.prestataireId == prestataireId,
      orElse: () => ConversationModel(
        id: "conv-${DateTime.now().millisecondsSinceEpoch}",
        prestataireId: prestataireId,
        prestataireNom: prestataireNom,
        prestatairePhoto: prestatairePhoto,
        lastMessage: "Nouvelle conversation entamée",
        lastMessageTime: DateTime.now(),
        articleRefTitre: articleRefTitre,
        articleRefImageUrl: articleRefImageUrl,
      ),
    );

    if (!_conversations.any((c) => c.id == existing.id)) {
      _conversations.insert(0, existing);
      _messagesByConv[existing.id] = [];
    }

    notifyListeners();
    return existing.id;
  }

  List<ChatMessageModel> getMessagesForConv(String convId) {
    return _messagesByConv[convId] ?? [];
  }

  void sendMessage({
    required String convId,
    required String text,
    String? articleRefTitre,
    String? articleRefImageUrl,
  }) {
    final msg = ChatMessageModel(
      id: "m-${DateTime.now().millisecondsSinceEpoch}",
      senderId: "user-1",
      text: text,
      timestamp: DateTime.now(),
      isFromUser: true,
      articleRefTitre: articleRefTitre,
      articleRefImageUrl: articleRefImageUrl,
    );

    if (_messagesByConv[convId] == null) {
      _messagesByConv[convId] = [];
    }
    _messagesByConv[convId]!.add(msg);

    final index = _conversations.indexWhere((c) => c.id == convId);
    if (index != -1) {
      final old = _conversations[index];
      _conversations[index] = ConversationModel(
        id: old.id,
        prestataireId: old.prestataireId,
        prestataireNom: old.prestataireNom,
        prestatairePhoto: old.prestatairePhoto,
        prestataireVerified: old.prestataireVerified,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        articleRefTitre: old.articleRefTitre,
        articleRefImageUrl: old.articleRefImageUrl,
      );
    }

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
