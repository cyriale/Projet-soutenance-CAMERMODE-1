import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Demande la permission pour la Caméra
  Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    try {
      var status = await Permission.camera.status;
      if (status.isGranted) return true;
      status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint("Permission Caméra: $e");
      return true;
    }
  }

  /// Demande la permission pour la Galerie (Photos / Médias)
  Future<bool> requestPhotosPermission() async {
    if (kIsWeb) return true;
    try {
      var status = await Permission.photos.status;
      if (status.isGranted) return true;
      
      status = await Permission.photos.request();
      if (!status.isGranted) {
        // Fallback pour anciennes versions Android
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) return true;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint("Permission Galerie: $e");
      return true;
    }
  }

  /// Demande la permission pour la Localisation
  Future<bool> requestLocationPermission() async {
    if (kIsWeb) return true;
    try {
      var status = await Permission.location.status;
      if (status.isGranted) return true;
      status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      debugPrint("Permission Localisation: $e");
      return true;
    }
  }

  /// Vérifie si toutes les permissions nécessaires pour le prestataire sont là
  Future<bool> checkPrestatairePermissions() async {
    if (kIsWeb) return true;
    final camera = await Permission.camera.isGranted;
    final location = await Permission.location.isGranted;
    return camera && location;
  }
}
