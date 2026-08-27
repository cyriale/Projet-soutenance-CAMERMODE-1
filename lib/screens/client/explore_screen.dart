
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Explorer", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: const Center(child: Text("Recherche coiffures, vêtements, prestataires...")),
    );
  }
}
