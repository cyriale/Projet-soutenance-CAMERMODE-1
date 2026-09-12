import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupérer un utilisateur par son UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("❌ Erreur getUser: $e");
      return null;
    }
  }

  // Mise à jour du profil physique complet (Mesures 3D et Morphologie)
  Future<bool> saveBodyMeasurements({
    required String uid,
    required Map<String, double> measurements,
    required String morphologieType,
  }) async {
    try {
      await _db.collection('users').doc(uid).update({
        ...measurements,
        'morphologieType': morphologieType,
        'hasBodyScan': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Mesures corporelles enregistrées pour $uid");
      return true;
    } catch (e) {
      debugPrint("❌ Erreur saveBodyMeasurements: $e");
      return false;
    }
  }

  // Mise à jour générique des informations de l'utilisateur
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("❌ Erreur updateUser: $e");
      return false;
    }
  }

  // Ancienne méthode pour compatibilité
  Future<bool> updatePhysicalProfile({
    required String uid,
    required double taille,
    required double poids,
    required String morphologie,
    required List<String> preferences,
  }) async {
    try {
      await _db.collection('users').doc(uid).update({
        'taille': taille,
        'poids': poids,
        'morphologieType': morphologie,
        'preferencesStyles': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("❌ Erreur updatePhysicalProfile: $e");
      return false;
    }
  }
}
