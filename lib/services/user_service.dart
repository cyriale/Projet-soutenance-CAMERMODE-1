import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // Ancienne méthode pour compatibilité ou mise à jour simple
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
