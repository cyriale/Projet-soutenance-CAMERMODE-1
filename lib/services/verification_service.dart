
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Téléverser un document et retourner son URL
  Future<String?> uploadDocument({
    required String userId,
    required File file,
    required String folderName,
  }) async {
    try {
      final ref = _storage.ref().child('verifications/$userId/$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Erreur uploadDocument: $e");
      return null;
    }
  }

  // Soumettre le dossier complet pour vérification
  Future<bool> submitVerification({
    required String userId,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      await _db.collection('users').doc(userId).update({
        ...verificationData,
        'verificationStatus': 'enAttente',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Erreur submitVerification: $e");
      return false;
    }
  }

  // Mettre à jour le statut (pour l'admin)
  Future<void> updateStatus(String userId, VerificationStatus status, {String? reason}) async {
    await _db.collection('users').doc(userId).update({
      'verificationStatus': status.toString().split('.').last,
      'rejectionReason': reason,
    });
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
