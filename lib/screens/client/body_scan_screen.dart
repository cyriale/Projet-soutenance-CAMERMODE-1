
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../compronents/app_button.dart';

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen> {
  int _currentStep = 0; // 0: Instructions, 1: Scan Frontal, 2: Scan Profil, 3: Analyse

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pour une immersion "Caméra"
      body: Stack(
        children: [
          // Ici viendra la preview de la caméra (ex: camera plugin)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.person_outline, size: 300, color: Colors.white24),
            ),
          ),

          // Overlay de guidage
          if (_currentStep == 1 || _currentStep == 2)
            Center(
              child: Container(
                width: 250,
                height: 500,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.rose, width: 2),
                  borderRadius: BorderRadius.circular(150),
                ),
              ),
            ),

          // UI de contrôle
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "SCAN 3D",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xB3000000), // Black with 70% opacity
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildStepContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            const Text(
              "Prêt pour votre scan physique ?",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Placez votre téléphone à hauteur de taille et reculez de 2 mètres.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: "COMMENCER LE SCAN",
              onPressed: () => setState(() => _currentStep = 1),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            const Text("VUE DE FACE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Tenez-vous bien droit dans le cadre.", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            FloatingActionButton(
              backgroundColor: AppColors.rose,
              onPressed: () => setState(() => _currentStep = 2),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ],
        );
      default:
        return const Center(child: CircularProgressIndicator(color: AppColors.rose));
    }
  }
}
