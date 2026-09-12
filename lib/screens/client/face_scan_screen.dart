import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';
import '../../services/ai_face_recognition_service.dart';
import '../../services/permission_service.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final AIFaceRecognitionService _faceService = AIFaceRecognitionService();
  final PermissionService _permissionService = PermissionService();

  XFile? _selectedImage;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  FaceAnalysisResult? _result;
  String _selectedHairType = "Crépus (4B / 4C)";

  final List<String> _hairTypes = [
    "Crépus (4B / 4C)",
    "Frisés (3C / 4A)",
    "Bouclés (3A / 3B)",
    "Défrisés / Lisses",
    "Locks / Dreadlocks",
  ];

  @override
  void dispose() {
    _faceService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    bool hasPermission = true;
    if (source == ImageSource.camera) {
      hasPermission = await _permissionService.requestCameraPermission();
    } else {
      hasPermission = await _permissionService.requestPhotosPermission();
    }

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission refusée.")),
        );
      }
      return;
    }

    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = picked;
          _isAnalyzing = true;
          _result = null;
        });

        final analysis = await _faceService.analyzeFace(picked);

        if (mounted) {
          setState(() {
            _result = analysis;
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'analyse : $e")),
        );
      }
    }
  }

  Future<void> _saveResults() async {
    if (_result == null) return;

    setState(() => _isSaving = true);
    final success = await _faceService.saveFaceScanToProfile(_result!, hairType: _selectedHairType);
    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan facial enregistré dans votre profil avec succès !"), backgroundColor: AppColors.succes),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'enregistrement."), backgroundColor: AppColors.erreur),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SCAN VISAGE & COIFFURE IA", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.1)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_selectedImage == null) ...[
              const SizedBox(height: 20),
              Container(
                width: 220,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(110),
                  border: Border.all(color: AppColors.rose, width: 2.5),
                  gradient: LinearGradient(
                    colors: [AppColors.rose.withOpacity(0.1), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.face_retouching_natural, size: 80, color: AppColors.rose),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Analyse Faciale par Intelligence Artificielle",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Prenez une photo de votre visage de face. L'IA détecte votre morphologie faciale (ovale, rond, carré, etc.) et vous recommande les meilleures coiffures africaines.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text("GALERIE", style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text("CAMÉRA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rose,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Image sélectionnée
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 200,
                  height: 240,
                  child: kIsWeb
                      ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                      : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),

              if (_isAnalyzing) ...[
                const CircularProgressIndicator(color: AppColors.rose),
                const SizedBox(height: 16),
                const Text("Analyse biométrique faciale en cours...", style: TextStyle(color: Colors.white70)),
              ] else if (_result != null) ...[
                // Résultats de l'analyse
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.rose.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Forme de Visage Détectée :", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              _result!.faceShape,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      const Text("Conseil de Style & Coiffure :", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(_result!.hairStyleRecommendations, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 16),
                      const Text("Styles Spécifiques Recommandés :", style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _result!.recommendedStyles.map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 11, color: Colors.white)),
                          backgroundColor: Colors.white10,
                          side: const BorderSide(color: Colors.white24),
                        )).toList(),
                      ),
                      const Divider(height: 28, color: Colors.white24),
                      const Text("Type de cheveux :", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedHairType,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black38,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                        ),
                        items: _hairTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _selectedHairType = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: "ENREGISTRER DANS MON PROFIL",
                  isLoading: _isSaving,
                  onPressed: _saveResults,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedImage = null;
                    _result = null;
                  }),
                  child: const Text("REPRENDRE UNE NOUVELLE PHOTO", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
