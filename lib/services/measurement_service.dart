
import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class MeasurementService {
  // Calcule la distance entre deux points en pixels
  double _distance(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  // Estime les mesures réelles basées sur la taille de l'utilisateur (en cm)
  Map<String, double> calculateMeasurements(Pose pose, double userHeightCm) {
    final landmarks = pose.landmarks;

    // Récupération des points clés
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder]!;
    final leftHip = landmarks[PoseLandmarkType.leftHip]!;
    final rightHip = landmarks[PoseLandmarkType.rightHip]!;
    final leftKnee = landmarks[PoseLandmarkType.leftKnee]!;
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle]!;
    final leftElbow = landmarks[PoseLandmarkType.leftElbow]!;
    final leftWrist = landmarks[PoseLandmarkType.leftWrist]!;

    // Calcul de la hauteur en pixels (du haut de l'épaule à la cheville comme approximation)
    double pixelHeight = _distance(leftShoulder, leftAnkle);
    double ratio = userHeightCm / pixelHeight;

    // Calcul des mesures estimées
    double shoulderWidth = _distance(leftShoulder, rightShoulder) * ratio;
    double armLength = (_distance(leftShoulder, leftElbow) + _distance(leftElbow, leftWrist)) * ratio;
    double legLength = (_distance(leftHip, leftKnee) + _distance(leftKnee, leftAnkle)) * ratio;
    double hipWidth = _distance(leftHip, rightHip) * ratio;

    return {
      'largeurEpaules': shoulderWidth,
      'longueurBras': armLength,
      'longueurJambe': legLength,
      'tourHanche': hipWidth * 2.5, // Approximation du tour basée sur la largeur frontale
      'tourPoitrine': shoulderWidth * 2.2, // Approximation
      'tourTaille': hipWidth * 1.8, // Approximation
    };
  }

  // Détermine la morphologie basée sur les rapports de largeur
  String determineMorphology(double shoulderWidth, double hipWidth, double waistWidth) {
    if (shoulderWidth > hipWidth * 1.1) return "V (Pyramide inversée)";
    if (hipWidth > shoulderWidth * 1.1) return "A (Pyramide)";
    if (shoulderWidth >= hipWidth * 0.95 && shoulderWidth <= hipWidth * 1.05) {
        if (waistWidth < shoulderWidth * 0.8) return "X (Sablier)";
        return "H (Rectangle)";
    }
    return "O (Ronde)";
  }
}
