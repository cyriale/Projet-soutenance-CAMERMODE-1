
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/article_model.dart';
import '../models/reservation_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import 'ai_recommendation_service.dart';
import 'article_service.dart';
import 'auth_service.dart';
import 'chat_service.dart';

class DashboardService extends ChangeNotifier {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;

  final AIRecommendationService _aiService = AIRecommendationService();
  final ArticleService _articleService = ArticleService();
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DashboardService._internal() {
    _listenToFirestoreArticles();
    _loadUserProfile();
  }

  void _listenToFirestoreArticles() {
    _db.collection('articles').snapshots().listen((snapshot) {
      _articles = snapshot.docs
          .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
          .where((art) => art.isPublished)
          .toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint("Erreur écoute articles Firestore : $e");
    });
  }

  UserModel? _currentUserProfile;
  UserModel? get currentUserProfile => _currentUserProfile;

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      debugPrint("⏳ _loadUserProfile: aucun utilisateur connecté pour le moment.");
      return;
    }

    try {
      final doc = await _db.collection('users').doc(user.uid).get().timeout(const Duration(seconds: 8));
      if (doc.exists && doc.data() != null) {
        _currentUserProfile = UserModel.fromMap(doc.data()!, user.uid);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ Erreur chargement profil utilisateur : $e");
    }

    // Charger les essayages sauvegardés de l'utilisateur depuis Firestore
    try {
      final tryOnsSnap = await _db
          .collection('users')
          .doc(user.uid)
          .collection('savedTryOns')
          .orderBy('date', descending: true)
          .get()
          .timeout(const Duration(seconds: 8));

      _savedTryOns.clear();
      for (final d in tryOnsSnap.docs) {
        final data = d.data();
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }
        if (data['aiResultBase64'] != null && data['aiResultBase64'] is String) {
          try {
            data['aiResultBytes'] = base64Decode(data['aiResultBase64']);
          } catch (_) {}
        }
        data['id'] = d.id;
        _savedTryOns.add(data);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Erreur chargement essayages sauvegardés : $e");
    }

    // Charger les likes, favoris, prestataires favoris, images sauvegardées, réservations et avis depuis Firestore
    try {
      final likesSnap = await _db
          .collection('users')
          .doc(user.uid)
          .collection('likes')
          .get()
          .timeout(const Duration(seconds: 8));

      _likedArticleIds.clear();
      for (final doc in likesSnap.docs) {
        _likedArticleIds.add(doc.id);
      }

      final favsSnap = await _db
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get()
          .timeout(const Duration(seconds: 8));

      _favoriteArticleIds.clear();
      for (final doc in favsSnap.docs) {
        _favoriteArticleIds.add(doc.id);
      }

      final favPrestSnap = await _db
          .collection('users')
          .doc(user.uid)
          .collection('favoritePrestataires')
          .get()
          .timeout(const Duration(seconds: 8));

      _favoritePrestataireIds.clear();
      for (final doc in favPrestSnap.docs) {
        _favoritePrestataireIds.add(doc.id);
      }

      final savedImgSnap = await _db
          .collection('users')
          .doc(user.uid)
          .collection('savedImages')
          .get()
          .timeout(const Duration(seconds: 8));

      _savedArticleIds.clear();
      for (final doc in savedImgSnap.docs) {
        _savedArticleIds.add(doc.id);
      }

      final resSnap = await _db
          .collection('reservations')
          .where('userId', isEqualTo: user.uid)
          .get()
          .timeout(const Duration(seconds: 8));

      _reservations.clear();
      for (final doc in resSnap.docs) {
        _reservations.add(ReservationModel.fromMap(doc.data(), doc.id));
      }

      final revSnap = await _db
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get()
          .timeout(const Duration(seconds: 8));

      _reviews.clear();
      for (final doc in revSnap.docs) {
        _reviews.add(ReviewModel.fromMap(doc.data(), doc.id));
      }

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Erreur chargement données Firestore : $e");
    }
  }

  Future<void> reloadUserProfile() async {
    await _loadUserProfile();
  }

  // Articles & Publications
  final Set<String> _likedArticleIds = {};
  bool isLiked(String articleId) => _likedArticleIds.contains(articleId);

  final Set<String> _favoriteArticleIds = {};
  bool isFavorite(String articleId) => _favoriteArticleIds.contains(articleId);

  List<ArticleModel> _articles = [];
  List<ArticleModel> get articles {
    return _articles.map((art) {
      return art.copyWith(
        isLiked: _likedArticleIds.contains(art.id),
        isFavorite: _favoriteArticleIds.contains(art.id),
      );
    }).toList();
  }

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



  // --- ACTIONS LIKES ---
  Future<void> toggleLike(String articleId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final bool currentlyLiked = _likedArticleIds.contains(articleId);
    final bool newLiked = !currentlyLiked;

    if (newLiked) {
      _likedArticleIds.add(articleId);
    } else {
      _likedArticleIds.remove(articleId);
    }

    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final art = _articles[index];
      final newCount = newLiked ? art.likesCount + 1 : art.likesCount - 1;
      _articles[index] = art.copyWith(
        isLiked: newLiked,
        likesCount: newCount < 0 ? 0 : newCount,
      );
    }
    notifyListeners();

    try {
      await _articleService.toggleLikeArticle(articleId, user.uid, newLiked);
    } catch (e) {
      debugPrint("Erreur toggleLike Firestore : $e");
    }
  }

  // --- ACTIONS FAVORIS ---
  Future<void> toggleFavorite(String articleId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final bool currentlyFav = _favoriteArticleIds.contains(articleId);
    final bool newFav = !currentlyFav;

    if (newFav) {
      _favoriteArticleIds.add(articleId);
    } else {
      _favoriteArticleIds.remove(articleId);
    }

    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isFavorite: newFav);
    }
    notifyListeners();

    try {
      if (newFav) {
        await _db.collection('users').doc(user.uid).collection('favorites').doc(articleId).set({
          'articleId': articleId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('users').doc(user.uid).collection('favorites').doc(articleId).delete();
      }
    } catch (e) {
      debugPrint("Erreur toggleFavorite Firestore : $e");
    }
  }

  Future<void> toggleFavoritePrestataire(String prestataireId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (_favoritePrestataireIds.contains(prestataireId)) {
      _favoritePrestataireIds.remove(prestataireId);
    } else {
      _favoritePrestataireIds.add(prestataireId);
    }
    notifyListeners();

    try {
      if (_favoritePrestataireIds.contains(prestataireId)) {
        await _db.collection('users').doc(user.uid).collection('favoritePrestataires').doc(prestataireId).set({
          'prestataireId': prestataireId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('users').doc(user.uid).collection('favoritePrestataires').doc(prestataireId).delete();
      }
    } catch (e) {
      debugPrint("Erreur toggleFavoritePrestataire Firestore : $e");
    }
  }

  // --- ACTIONS ENREGISTREMENTS D'IMAGES (Mes Sauvegardes) ---
  Future<void> toggleSaveImage(String articleId) async {
    final user = _authService.currentUser;
    if (user == null) return;

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

    try {
      if (_savedArticleIds.contains(articleId)) {
        await _db.collection('users').doc(user.uid).collection('savedImages').doc(articleId).set({
          'articleId': articleId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('users').doc(user.uid).collection('savedImages').doc(articleId).delete();
      }
    } catch (e) {
      debugPrint("Erreur toggleSaveImage Firestore : $e");
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(status: ReservationStatus.annulee);
      notifyListeners();
    }

    try {
      await _db.collection('reservations').doc(reservationId).update({
        'status': ReservationStatus.annulee.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Erreur cancelReservation Firestore : $e");
    }
  }

  // --- ACTIONS AVIS ---
  Future<void> addReview({
    required String reservationId,
    required String prestataireId,
    required double rating,
    required String commentaire,
    required String serviceTitre,
    String? photoUrl,
  }) async {
    final user = _authService.currentUser;
    final userId = user?.uid ?? "user-1";
    final userNom = _currentUserProfile?.prenom ?? "Utilisateur";

    final newReview = ReviewModel(
      id: "rev-${DateTime.now().millisecondsSinceEpoch}",
      reservationId: reservationId,
      prestataireId: prestataireId,
      userId: userId,
      userNom: userNom,
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

    try {
      await _db.collection('reviews').add({
        ...newReview.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (resIndex != -1) {
        await _db.collection('reservations').doc(reservationId).update({
          'hasReview': true,
        });
      }
    } catch (e) {
      debugPrint("Erreur addReview Firestore : $e");
    }
  }

  Future<void> deleteReview(String reviewId) async {
    _reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();

    try {
      final query = await _db.collection('reviews').where('id', isEqualTo: reviewId).get();
      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Erreur deleteReview Firestore : $e");
    }
  }

  // --- ACTIONS ESSAYAGE VIRTUEL ---
  Future<void> saveTryOnResult({
    required String articleId,
    required String articleTitre,
    required String colorName,
    required String size,
    required String imageUrl,
    Uint8List? aiResultBytes,
  }) async {
    String? aiResultBase64;
    if (aiResultBytes != null) {
      aiResultBase64 = base64Encode(aiResultBytes);
    }

    final tryOnData = {
      "articleId": articleId,
      "articleTitre": articleTitre,
      "colorName": colorName,
      "size": size,
      "imageUrl": imageUrl,
      "aiResultBase64": aiResultBase64,
      "date": FieldValue.serverTimestamp(),
    };

    _savedTryOns.insert(0, {
      "id": "try-${DateTime.now().millisecondsSinceEpoch}",
      "articleId": articleId,
      "articleTitre": articleTitre,
      "colorName": colorName,
      "size": size,
      "imageUrl": imageUrl,
      "aiResultBytes": aiResultBytes,
      "aiResultBase64": aiResultBase64,
      "date": DateTime.now(),
    });
    notifyListeners();

    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('savedTryOns')
            .add(tryOnData);
      } catch (e) {
        debugPrint("Erreur sauvegarde essayage Firestore : $e");
      }
    }
  }
}
