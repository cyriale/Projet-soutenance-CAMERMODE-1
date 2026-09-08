
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/article_model.dart';
import 'package:flutter/foundation.dart';

class ArticleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Créer un nouvel article (Upload image + Save metadata)
  Future<bool> uploadArticle({
    required String prestataireId,
    required String prestataireNom,
    required String prestatairePhoto,
    required XFile imageFile,
    required String titre,
    required String description,
    required double prix,
    required ArticleType type,
    required String categorie,
    required List<String> tags,
  }) async {
    try {
      // 1. Upload de l'image
      final ref = _storage.ref().child('articles/$prestataireId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // 2. Création de l'objet Article
      final article = ArticleModel(
        id: "", // Sera généré par Firestore
        prestataireId: prestataireId,
        prestataireNom: prestataireNom,
        prestatairePhoto: prestatairePhoto,
        titre: titre,
        description: description,
        prix: prix,
        imageUrl: imageUrl,
        type: type,
        categorie: categorie,
        tags: tags,
        likesCount: 0,
      );

      // 3. Sauvegarde dans Firestore
      await _db.collection('articles').add(article.toMap());
      return true;
    } catch (e) {
      debugPrint("Erreur uploadArticle: $e");
      return false;
    }
  }

  // Récupérer le flux de tous les articles (pour le client)
  Stream<List<ArticleModel>> getAllArticles() {
    return _db.collection('articles')
        .orderBy('likesCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
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
    if (isLiked) {
      await ref.update({
        'likesCount': FieldValue.increment(1),
        // On pourrait aussi ajouter le userId dans une sous-collection 'likes'
      });
    } else {
      await ref.update({
        'likesCount': FieldValue.increment(-1),
      });
    }
  }
}
