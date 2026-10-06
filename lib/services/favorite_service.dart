import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FAVORIS ARTICLES ---
  Future<void> toggleFavoriteArticle(String userId, String articleId) async {
    if (userId.isEmpty || articleId.isEmpty) return;
    try {
      final docRef = _db.collection('users').doc(userId).collection('favorites').doc(articleId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'articleId': articleId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("❌ Erreur toggleFavoriteArticle: $e");
    }
  }

  Stream<Set<String>> getUserFavoriteArticleIds(String userId) {
    if (userId.isEmpty) return Stream.value({});
    return _db.collection('users').doc(userId).collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  // --- FAVORIS PRESTATAIRES ---
  Future<void> toggleFavoritePrestataire(String userId, String prestataireId) async {
    if (userId.isEmpty || prestataireId.isEmpty) return;
    try {
      final docRef = _db.collection('users').doc(userId).collection('favorite_prestataires').doc(prestataireId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'prestataireId': prestataireId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("❌ Erreur toggleFavoritePrestataire: $e");
    }
  }

  Stream<Set<String>> getUserFavoritePrestataireIds(String userId) {
    if (userId.isEmpty) return Stream.value({});
    return _db.collection('users').doc(userId).collection('favorite_prestataires')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  // --- SAUVEGARDES D'IMAGES (MOODBOARD) ---
  Future<void> toggleSaveImage(String userId, String articleId) async {
    if (userId.isEmpty || articleId.isEmpty) return;
    try {
      final docRef = _db.collection('users').doc(userId).collection('saved_images').doc(articleId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'articleId': articleId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("❌ Erreur toggleSaveImage: $e");
    }
  }

  Stream<Set<String>> getUserSavedImageIds(String userId) {
    if (userId.isEmpty) return Stream.value({});
    return _db.collection('users').doc(userId).collection('saved_images')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }
}
