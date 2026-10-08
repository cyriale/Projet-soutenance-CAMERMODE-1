import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  // Demander et obtenir la position actuelle (avec fallback par défaut à Douala si GPS désactivé ou refusé)
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getDefaultPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getDefaultPosition();
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return _getDefaultPosition();
      } 

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Erreur GPS, utilisation de la position par défaut (Douala) : $e");
      return _getDefaultPosition();
    }
  }

  Position _getDefaultPosition() {
    return Position(
      latitude: 4.0511,
      longitude: 9.7679,
      timestamp: DateTime.now(),
      accuracy: 100.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  // Calculer la distance entre deux points en km
  double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
    double distanceInMeters = Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
    return distanceInMeters / 1000;
  }
}
