
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PrestataireExploreScreen extends StatelessWidget {
  const PrestataireExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      appBar: AppBar(
        title: const Text("Tendances & Inspiration", style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Ce qui plaît aux clients en ce moment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          _buildTrendCard("Styles populaires", "Les tresses royales sont en tête ce mois-ci."),
          _buildTrendCard("Articles favoris", "La robe de gala Émeraude a été essayée 150 fois."),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rose)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppColors.texteSecondaire)),
        ],
      ),
    );
  }
}
