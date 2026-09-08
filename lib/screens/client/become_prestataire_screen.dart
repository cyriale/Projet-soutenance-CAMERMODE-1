
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../auth/prestataire_registration_stepper.dart';

class BecomePrestataireScreen extends StatelessWidget {
  const BecomePrestataireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Devenir Prestataire", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.noir),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.verified_user, size: 100, color: AppColors.rose),
            const SizedBox(height: 32),
            const Text(
              "Rejoignez la communauté pro",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Pour garantir la sécurité et la confiance de nos utilisateurs, nous devons vérifier votre identité et votre activité professionnelle.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.texteSecondaire, fontSize: 16),
            ),
            const SizedBox(height: 64),
            const Text(
              "PRÊT À OFFICIALISER VOTRE TALENT ?",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.rose, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrestataireRegistrationStepper()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rose, 
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("LANCER MA CERTIFICATION PRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  Text("Action finale irréversible", style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Une fois le processus lancé, votre demande sera examinée par nos experts pour valider votre boutique.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "NON MERCI, GARDER MON COMPTE CLIENT",
                style: TextStyle(
                  color: AppColors.texteGris,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
