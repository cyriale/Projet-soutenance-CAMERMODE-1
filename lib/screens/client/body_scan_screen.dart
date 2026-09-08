import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';
import '../../views_models/client/body_scan_view_model.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  final TextEditingController _heightController = TextEditingController(text: "170");
  int _currentStep = 0; // 0: Infos, 1: Caméra, 2: Résultats

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BodyScanViewModel(),
      child: Consumer<BodyScanViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text("SCAN MORPHOLOGIQUE", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.2)),
            ),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BodyScanViewModel viewModel) {
    if (_currentStep == 0) return _stepInstructions(viewModel);
    if (_currentStep == 1) return _stepCamera(viewModel);
    return _stepResults(viewModel);
  }

  Widget _stepInstructions(BodyScanViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.accessibility_new, size: 80, color: AppColors.rose),
          const SizedBox(height: 24),
          const Text(
            "Précision du Scan",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Pour calculer vos mesures, nous avons besoin de votre taille réelle.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Votre taille (cm)",
              labelStyle: const TextStyle(color: AppColors.rose),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.rose), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 48),
          AppButton(
            text: "OUVRIR LA CAMÉRA",
            onPressed: () async {
              await viewModel.initializeCamera();
              setState(() => _currentStep = 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _stepCamera(BodyScanViewModel viewModel) {
    return Stack(
      children: [
        if (viewModel.isCameraInitialized)
          Positioned.fill(child: CameraPreview(viewModel.cameraController!))
        else
          const Center(child: CircularProgressIndicator(color: AppColors.rose)),
        
        // Overlay silhouette
        Center(
          child: Container(
            width: 280,
            height: 550,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.rose.withValues(alpha: 0.5), width: 2),
              borderRadius: BorderRadius.circular(140),
            ),
          ),
        ),

        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                "Placez votre corps entier dans le cadre",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black45),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: viewModel.isLoading ? null : () async {
                  final height = double.tryParse(_heightController.text) ?? 170.0;
                  await viewModel.captureAndProcess(height);
                  if (viewModel.isScanComplete) {
                    setState(() => _currentStep = 2);
                  }
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: viewModel.isLoading 
                      ? const CircularProgressIndicator(color: AppColors.rose)
                      : Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepResults(BodyScanViewModel viewModel) {
    final m = viewModel.lastMeasurements;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Analyse Terminée ✅",
              style: TextStyle(color: AppColors.rose, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "Morphologie détectée : ${viewModel.morphology}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
          const Text("VOS MESURES ESTIMÉES :", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          _resultItem("Tour de Poitrine", "${m?['tourPoitrine']?.toStringAsFixed(1)} cm"),
          _resultItem("Tour de Taille", "${m?['tourTaille']?.toStringAsFixed(1)} cm"),
          _resultItem("Tour de Hanche", "${m?['tourHanche']?.toStringAsFixed(1)} cm"),
          _resultItem("Largeur Épaules", "${m?['largeurEpaules']?.toStringAsFixed(1)} cm"),
          _resultItem("Longueur Bras", "${m?['longueurBras']?.toStringAsFixed(1)} cm"),
          _resultItem("Longueur Jambe", "${m?['longueurJambe']?.toStringAsFixed(1)} cm"),
          const SizedBox(height: 40),
          AppButton(
            text: "ENREGISTRER DANS MON PROFIL",
            isLoading: viewModel.isLoading,
            onPressed: () async {
              final success = await viewModel.saveResults();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil mis à jour avec succès !"), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              }
            },
          ),
          TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Center(child: Text("REPRENDRE LE SCAN", style: TextStyle(color: Colors.white70))),
          ),
        ],
      ),
    );
  }

  Widget _resultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(value, style: const TextStyle(color: AppColors.rose, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
