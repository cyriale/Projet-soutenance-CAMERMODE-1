import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/availability_model.dart';

class AvailabilityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupérer la disponibilité sous forme de Stream (temps réel)
  Stream<AvailabilityModel> getAvailabilityStream(String prestataireId) {
    return _db.collection('availabilities').doc(prestataireId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AvailabilityModel.fromMap(doc.data()!, prestataireId);
      }
      return AvailabilityModel.defaultAvailability(prestataireId);
    });
  }

  // Récupérer la disponibilité une seule fois
  Future<AvailabilityModel> getAvailability(String prestataireId) async {
    try {
      final doc = await _db.collection('availabilities').doc(prestataireId).get();
      if (doc.exists && doc.data() != null) {
        return AvailabilityModel.fromMap(doc.data()!, prestataireId);
      }
    } catch (e) {
      debugPrint("Erreur getAvailability: $e");
    }
    return AvailabilityModel.defaultAvailability(prestataireId);
  }

  // Enregistrer ou mettre à jour la disponibilité complète
  Future<bool> saveAvailability(AvailabilityModel availability) async {
    try {
      await _db.collection('availabilities').doc(availability.prestataireId).set(
        availability.toMap(),
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      debugPrint("Erreur saveAvailability: $e");
      return false;
    }
  }

  // Ajouter un créneau horaire pour un jour spécifique
  Future<bool> addTimeSlotToDay(String prestataireId, String day, String newSlot) async {
    try {
      final current = await getAvailability(prestataireId);
      final updatedDaySlots = Map<String, List<String>>.from(current.daySlots);
      
      if (updatedDaySlots[day] == null) {
        updatedDaySlots[day] = [];
      }

      if (!updatedDaySlots[day]!.contains(newSlot)) {
        updatedDaySlots[day]!.add(newSlot);
        updatedDaySlots[day]!.sort();
        await saveAvailability(current.copyWith(daySlots: updatedDaySlots));
      }
      return true;
    } catch (e) {
      debugPrint("Erreur addTimeSlotToDay: $e");
      return false;
    }
  }

  // Supprimer un créneau horaire pour un jour spécifique
  Future<bool> deleteTimeSlotFromDay(String prestataireId, String day, String slotToDelete) async {
    try {
      final current = await getAvailability(prestataireId);
      final updatedDaySlots = Map<String, List<String>>.from(current.daySlots);
      
      if (updatedDaySlots[day] != null) {
        updatedDaySlots[day]!.remove(slotToDelete);
        await saveAvailability(current.copyWith(daySlots: updatedDaySlots));
      }
      return true;
    } catch (e) {
      debugPrint("Erreur deleteTimeSlotFromDay: $e");
      return false;
    }
  }
}
