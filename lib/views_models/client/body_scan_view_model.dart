import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../services/measurement_service.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class BodyScanViewModel extends ChangeNotifier {
  final MeasurementService _measurementService = MeasurementService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  PoseDetector? _poseDetector;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  bool get isCameraInitialized => _isCameraInitialized;

  Map<String, double>? _lastMeasurements;
  Map<String, double>? get lastMeasurements => _lastMeasurements;

  String? _morphology;
  String? get morphology => _morphology;

  bool _isScanComplete = false;
  bool get isScanComplete => _isScanComplete;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    _poseDetector = PoseDetector(options: PoseDetectorOptions());

    try {
      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur initialisation caméra: $e");
    }
  }

  Future<void> captureAndProcess(double userHeightCm) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) return;

    _isProcessing = true;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Capturer l'image
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // 2. Détecter la pose avec ML Kit
      final poses = await _poseDetector!.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;

        // 3. Calculer les mesures via le service
        _lastMeasurements = _measurementService.calculateMeasurements(pose, userHeightCm);
        
        // 4. Déterminer la morphologie
        final shoulderWidth = _lastMeasurements!['largeurEpaules']!;
        final hipWidth = _lastMeasurements!['tourHanche']! / 2.5;
        // Approximation de la taille pour la morphologie
        final waistWidth = hipWidth * 0.8; 
        
        _morphology = _measurementService.determineMorphology(shoulderWidth, hipWidth, waistWidth);
        _isScanComplete = true;
      }
    } catch (e) {
      debugPrint("Erreur pendant le scan: $e");
    } finally {
      _isProcessing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveResults() async {
    final user = _authService.currentUser;
    if (user == null || _lastMeasurements == null || _morphology == null) return false;

    _isLoading = true;
    notifyListeners();

    final success = await _userService.saveBodyMeasurements(
      uid: user.uid,
      measurements: _lastMeasurements!,
      morphologieType: _morphology!,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }
}
