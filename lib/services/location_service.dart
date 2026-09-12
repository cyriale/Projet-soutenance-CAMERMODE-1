
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  // Demander et obtenir la position actuelle
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Le service de localisation est désactivé.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées. Veuillez les activer dans les réglages.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return Future.error('Les permissions de localisation sont refusées de façon permanente.');
    } 

    // Obtenir la position
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint("Erreur getCurrentPosition: $e");
      return null;
    }
  }

  // Calculer la distance entre deux points en km
  double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
    double distanceInMeters = Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
    return distanceInMeters / 1000;
  }
}
