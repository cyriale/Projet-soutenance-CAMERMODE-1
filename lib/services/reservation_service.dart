import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import 'package:flutter/foundation.dart';

class ReservationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Vérifier si un créneau est déjà pris
  Future<bool> isSlotTaken({
    required String prestataireId,
    required DateTime date,
    required String heure,
  }) async {
    final query = await _db.collection('reservations')
        .where('prestataireId', isEqualTo: prestataireId)
        .where('heure', isEqualTo: heure)
        .get();

    for (var doc in query.docs) {
      final resDate = DateTime.tryParse(doc.data()['date'] ?? "");
      if (resDate != null && 
          resDate.year == date.year && 
          resDate.month == date.month && 
          resDate.day == date.day &&
          (doc.data()['status'] == 'enAttente' || doc.data()['status'] == 'acceptee')) {
        return true;
      }
    }
    return false;
  }

  // Créer une nouvelle réservation
  Future<bool> createReservation(ReservationModel reservation) async {
    try {
      await _db.collection('reservations').add(reservation.toMap());
      return true;
    } catch (e) {
      debugPrint("Erreur createReservation: $e");
      return false;
    }
  }

  // Récupérer les réservations d'un client
  Stream<List<ReservationModel>> getClientReservations(String userId) {
    return _db.collection('reservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // Récupérer TOUTES les réservations pour le prestataire (garantit l'affichage de toutes les commandes)
  Stream<List<ReservationModel>> getPrestataireReservations(String prestataireId) {
    return _db.collection('reservations')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ReservationModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // Mettre à jour le statut d'une réservation
  Future<void> updateReservationStatus(String resId, ReservationStatus status) async {
    await _db.collection('reservations').doc(resId).update({
      'status': status.name,
    });
  }
}
