
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PrestataireHomeScreen extends StatelessWidget {
  const PrestataireHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Tableau de bord", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text("Bienvenue, Prestataire ! Vos stats ici."),
      ),
    );
  }
}
