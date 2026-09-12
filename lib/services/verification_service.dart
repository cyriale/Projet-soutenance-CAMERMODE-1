
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Téléverser un document et retourner son URL
  Future<String?> uploadDocument({
    required String userId,
    required XFile file,
    required String folderName,
  }) async {
    try {
      final ref = _storage.ref().child('verifications/$userId/$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      if (kIsWeb) {
        // Pour le Web, on utilise les bytes
        final bytes = await file.readAsBytes();
        final uploadTask = await ref.putData(bytes);
        return await uploadTask.ref.getDownloadURL();
      } else {
        // Pour Mobile, on utilise le chemin du fichier (File n'est plus importé mais putFile accepte le chemin via un plugin interne ou on peut utiliser putData)
        // Pour rester 100% compatible Web sans import dart:io, on utilise putData partout
        final bytes = await file.readAsBytes();
        final uploadTask = await ref.putData(bytes);
        return await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint("Erreur uploadDocument: $e");
      return null;
    }
  }

  // Soumettre le dossier complet pour vérification
  Future<bool> submitVerification({
    required String userId,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      await _db.collection('users').doc(userId).set({
        ...verificationData,
        'verificationStatus': 'enAttente',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Erreur submitVerification: $e");
      return false;
    }
  }

  // Mettre à jour le statut (pour l'admin)
  Future<void> updateStatus(String userId, VerificationStatus status, {String? reason}) async {
    final statusStr = status.toString().split('.').last;
    Map<String, dynamic> updateData = {
      'verificationStatus': statusStr,
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    // Si validé, on s'assure que le motif de rejet précédent est réinitialisé si non spécifié
    if (status == VerificationStatus.verifie && reason == null) {
      updateData['rejectionReason'] = null;
    }
    await _db.collection('users').doc(userId).set(updateData, SetOptions(merge: true));
  }

  // Obtenir le flux de demandes en attente (pour l'admin)
  Stream<List<UserModel>> getPendingVerifications() {
    return _db
        .collection('users')
        .where('verificationStatus', isEqualTo: 'enAttente')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
