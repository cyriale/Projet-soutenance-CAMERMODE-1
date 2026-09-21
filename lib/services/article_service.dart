import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article_model.dart';
import 'package:flutter/foundation.dart';
import 'stockimg_client.dart';

class ArticleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Utilisation du nouveau client StockImg
  final StockImgClient _stockImg = StockImgClient();

  // Créer un nouvel article
  Future<bool> uploadArticle({
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    String? prestataireAdresse,
    bool? prestationADomicile,
    required XFile imageFile,
    required String titre,
    required String description,
    required double prix,
    required ArticleType type,
    required String categorie,
    required List<String> tags,
    bool isPublished = true,
  }) async {
    try {
      debugPrint("🚀 [ArticleService] Début uploadArticle pour : $titre");

      // 1. Upload de l'image via StockImg
      final String? imageUrl = await _stockImg.uploadXFile(imageFile);
      
      if (imageUrl == null) {
        debugPrint("❌ [ArticleService] L'upload de l'image a échoué.");
        return false;
      }

      debugPrint("✅ [ArticleService] Image uploadée : $imageUrl");

      // 2. Pré-génération de l'ID Firestore
      final docRef = _db.collection('articles').doc();

      // 3. Création de l'objet Article complet via le modèle
      final article = ArticleModel(
        id: docRef.id,
        prestataireId: prestataireId,
        prestataireNom: prestataireNom,
        prestatairePhoto: prestatairePhoto,
        prestataireRating: 4.8,
        prestataireAvisCount: 10,
        prestataireVerified: true,
        prestataireAdresse: prestataireAdresse ?? "Douala / Yaoundé",
        prestationADomicile: prestationADomicile ?? true,
        titre: titre,
        description: description,
        prix: prix,
        imageUrl: imageUrl,
        type: type,
        categorie: categorie,
        tags: tags,
        likesCount: 0,
        isPublished: isPublished,
      );

      // 4. Sauvegarde directe dans Firestore
      await docRef.set({
        ...article.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint("✨ [ArticleService] Article enregistré avec succès !");
      return true;
    } catch (e, stackTrace) {
      debugPrint("❌ [ArticleService] ERREUR CRITIQUE : $e");
      debugPrint("Stacktrace: $stackTrace");
      return false;
    }
  }

  // Mettre à jour un article existant
  Future<bool> updateArticle({
    required String articleId,
    required String titre,
    required String description,
    required double prix,
    required ArticleType type,
    required String categorie,
    required List<String> tags,
    required bool isPublished,
    XFile? newImageFile,
    String? currentImageUrl,
    String? prestataireId,
  }) async {
    try {
      String finalImageUrl = currentImageUrl ?? '';
      
      // Si une nouvelle image est fournie, on l'uploade
      if (newImageFile != null) {
        final String? uploadedUrl = await _stockImg.uploadXFile(newImageFile);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      await _db.collection('articles').doc(articleId).update({
        'titre': titre,
        'description': description,
        'prix': prix,
        'type': type.name,
        'categorie': categorie,
        'tags': tags,
        'isPublished': isPublished,
        'imageUrl': finalImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("❌ [ArticleService] Erreur updateArticle: $e");
      return false;
    }
  }

  // Supprimer un article
  Future<bool> deleteArticle(String articleId) async {
    try {
      await _db.collection('articles').doc(articleId).delete();
      return true;
    } catch (e) {
      debugPrint("❌ [ArticleService] Erreur deleteArticle: $e");
      return false;
    }
  }

  // Basculer l'état de publication (Publié <-> Brouillon)
  Future<bool> togglePublishStatus(String articleId, bool currentStatus) async {
    try {
      await _db.collection('articles').doc(articleId).update({
        'isPublished': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("❌ [ArticleService] Erreur togglePublishStatus: $e");
      return false;
    }
  }

  // Récupérer le flux de tous les articles
  Stream<List<ArticleModel>> getAllArticles() {
    return _db.collection('articles')
        .orderBy('likesCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
            .where((art) => art.isPublished)
            .toList());
  }

  // Récupérer les articles d'un prestataire spécifique
  Stream<List<ArticleModel>> getPrestataireArticles(String prestataireId) {
    return _db.collection('articles')
        .where('prestataireId', isEqualTo: prestataireId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Liker un article
  Future<void> toggleLikeArticle(String articleId, String userId, bool isLiked) async {
    final ref = _db.collection('articles').doc(articleId);
    await ref.update({
      'likesCount': FieldValue.increment(isLiked ? 1 : -1),
    });
  }
}
